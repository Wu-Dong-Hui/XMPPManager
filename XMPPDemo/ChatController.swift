//
//  ChatController.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/4.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ChatController: JSQMessagesViewController, JSQMessagesComposerTextViewPasteDelegate, ZPIMChatManagerDelegate {
    var messages = [JSQMessage]()
    private var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.grayColor())
    private var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.orangeColor())
    
    private var incomingAvatar = JSQMessagesAvatarImageFactory().avatarImageWithUserInitials("adm", backgroundColor: UIColor.grayColor(), textColor: UIColor.redColor(), font: UIFont.systemFontOfSize(12))
    private var outgoingAvatar = JSQMessagesAvatarImageFactory().avatarImageWithUserInitials("roy", backgroundColor: UIColor.orangeColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        inputToolbar.contentView?.textView?.pasteDelegate = self
        inputToolbar.contentView?.textView?.returnKeyType = .Send
        
        loadDemoMessages()
        
        ZPIMClient.sharedClient.chatManager.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.collectionViewLayout.springinessEnabled = false
        inputToolbar.enablesSendButtonAutomatically = true
        inputToolbar.sendButtonOnRight = true
    }
    
    func loadDemoMessages() {
        for index in 0...4 {
            let m = JSQMessage(senderId: index % 2 == 0 ? senderId() : chatToId(), displayName: index % 2 == 0 ? senderDisplayName() : chatToDisplayName(), text: "message index : \(index)")
            messages.append(m)
        }
        collectionView?.reloadData()
    }
    
    
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        let textBody = ZPIMTextMessageBody(text: text)
        let imMsg = ZPIMMessage(conversationId: "cid", from: senderId, to: "admin", body: textBody, ext: nil)
        ZPIMClient.sharedClient.chatManager.asyncSendMessage(imMsg, progress: nil) { [weak self] (message, error) -> (Void) in
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            self?.messages.append(message)
            dispatch_async(dispatch_get_main_queue(), { 
                self?.finishSendingMessageAnimated(true)
            })
            
        }
        
    }
    func didReceiveMessages(messages: Array<ZPIMMessage>) {
        var latestMessages = [JSQMessage]()
        for imMsg in messages {
            if let textBody = imMsg.body as? ZPIMTextMessageBody {
                let jsqMsg = JSQMessage(senderId: chatToId(), displayName: chatToDisplayName(), text: textBody.text)
                latestMessages.append(jsqMsg)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.messages.appendContentsOf(latestMessages)
            self.finishSendingMessageAnimated(true)
        }
    }
    override func didPressAccessoryButton(sender: UIButton) {
        NSLog("didPressAccessoryButton \(sender)")
    }
    func chatToId() -> String {
        return "admin@127.0.0.1"
    }
    func chatToDisplayName() -> String {
        return "admin"
    }
    override func senderId() -> String {
        return "test1@127.0.0.1"
    }
    override func senderDisplayName() -> String {
        return "roy"
    }
    //MARK: - JSQ collection view data source
    override func collectionView(collectionView: JSQMessagesCollectionView, messageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, didDeleteMessageAtIndexPath indexPath: NSIndexPath) {
        messages.removeAtIndex(indexPath.item)
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource? {
        let m = messages[indexPath.item]
        if m.senderId == senderId() {
            return outgoingBubble
        }
        return incomingBubble
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource? {
        let m = messages[indexPath.item]
        if m.senderId == senderId() {
            return outgoingAvatar
        }
        return incomingAvatar
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        return nil
    }
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        return nil
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        
        
        return cell
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //MARK: - JSQMessagesComposerTextViewPasteDelegate
    func composerTextView(textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: AnyObject) -> Bool {
        if let img = UIPasteboard.generalPasteboard().image {
            let photoItem = JSQPhotoMediaItem(image: img)
            let message = JSQMessage(senderId: senderId(), displayName: senderDisplayName(), media: photoItem)
            messages.append(message)
        }
        return false
    }
    //MARK: - deinit
    deinit {
        ZPIMClient.sharedClient.chatManager.removeDelegate(self)
    }
}
