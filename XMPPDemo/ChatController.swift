//
//  ChatController.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/4.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ChatController: JSQMessagesViewController, JSQMessagesComposerTextViewPasteDelegate, ZPIMChatManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var conversation: Conversation!
    
    var messages = [JSQMessage]()
    private var incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.grayColor())
    private var outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.orangeColor())
    
    private var incomingAvatar = JSQMessagesAvatarImageFactory().avatarImageWithUserInitials("adm", backgroundColor: UIColor.grayColor(), textColor: UIColor.redColor(), font: UIFont.systemFontOfSize(12))
    private var outgoingAvatar = JSQMessagesAvatarImageFactory().avatarImageWithUserInitials("roy", backgroundColor: UIColor.orangeColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12))
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = chatToDisplayName()
        
        view.backgroundColor = UIColor.whiteColor()
        
        inputToolbar.contentView?.textView?.pasteDelegate = self
        inputToolbar.contentView?.textView?.returnKeyType = .Send
        
        let back = UIBarButtonItem(title: "close", style: .Done, target: self, action: #selector(self.back))
        navigationItem.leftBarButtonItem = back
        
//        loadDemoMessages()
        loadHistoryMessages()
        
        ZPIMClient.sharedClient.chatManager.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.collectionViewLayout.springinessEnabled = false
        inputToolbar.enablesSendButtonAutomatically = true
        inputToolbar.sendButtonOnRight = true
    }
    //MARK: - scroll view delegate
    
    //MARK: - private
    func back() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func loadHistoryMessages(count: Int = 20) {
        guard let user = ZPIMClient.sharedClient.getUserName() else {
            DDLogError("please login first")
            return
        }
        Utility.get("getChatLogs", paras: ["jid" : user]) { [weak self] (json, error, msg) in
            if json != nil {
                for message in json as! [[String: AnyObject]] {
                    let jsqMsg = JSQMessage(senderId: message["from"] as! String, displayName: message["from"] as! String, text: message["text"] as! String)
                    self?.messages.append(jsqMsg)
                }
                self?.collectionView?.reloadData()
            } else {
                DDLogError("\(error)")
            }
        }
    }
    func loadDemoMessages() {
        for index in 0...4 {
            let m = JSQMessage(senderId: index % 2 == 0 ? senderId() : chatToId(), displayName: index % 2 == 0 ? senderDisplayName() : chatToDisplayName(), text: "message index : \(index)")
            messages.append(m)
        }
        collectionView?.reloadData()
    }
    func chatToId() -> String {
        return conversation.jid
    }
    func chatToDisplayName() -> String {
        return conversation.nick
    }
    //MARK: - override from super
    override func didPressSendButton(button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        let textBody = ZPIMTextMessageBody(text: text)
        let imMsg = ZPIMMessage(conversationId: "cid", from: senderId, to: chatToId(), body: textBody, ext: nil)
        ZPIMClient.sharedClient.chatManager.asyncSendMessage(imMsg, progress: nil) { [weak self] (message, error) -> (Void) in
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            self?.messages.append(message)
            dispatch_async(dispatch_get_main_queue(), { 
                self?.finishSendingMessageAnimated(true)
            })
            
        }
        
    }
    override func didPressAccessoryButton(sender: UIButton) {
        let actionSheet = UIActionSheet(title: "更多", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("图片")
//        actionSheet.addButtonWithTitle("视频")
        actionSheet.showFromToolbar(inputToolbar)
    }
    override func senderId() -> String {
        return "test1"
    }
    override func senderDisplayName() -> String {
        return "roy"
    }
    //MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let picker = UIImagePickerController()
            picker.delegate = self
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                picker.sourceType = .PhotoLibrary
            }
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        DDLogDebug("\(editingInfo)")
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let mediaItem = JSQPhotoMediaItem(image: image)
        let message = JSQMessage(senderId: senderId(), displayName: senderDisplayName(), media: mediaItem)
        messages.append(message)
        dispatch_async(dispatch_get_main_queue(), {
            self.finishSendingMessageAnimated(true)
        })
        /*
        let data = UIImageJPEGRepresentation(image, 0.3)!
        Utility.post("upload", paras: ["": ""], progress: { (progress) in
            DDLogDebug("\(Float(progress.completedUnitCount) / Float(progress.totalUnitCount))")
            }, constructingBodyWithBlock: { (formData) in
                formData.appendPartWithFileData(data, name: "name", fileName: "name.jpg", mimeType: "png")
        }) { [weak self] (json, error, msg) in
            if json != nil {
                DDLogDebug("upload success")
                let url = json as! String
                let imageBody = ZPIMImageMessageBody(data: data, displayName: "image")
                imageBody.reomotePath = url
                let imMsg = ZPIMMessage(conversationId: "cid", from: self!.senderId(), to: self!.chatToId(), body: imageBody, ext: nil)
                ZPIMClient.sharedClient.chatManager.asyncSendMessage(imMsg, progress: nil) { [weak self] (message, error) -> (Void) in
                    let mediaItem = JSQPhotoMediaItem(image: image)
                    let message = JSQMessage(senderId: self!.senderId(), displayName: self!.senderDisplayName(), media: mediaItem)
                    self?.messages.append(message)
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.finishSendingMessageAnimated(true)
                    })
                    
                }
            } else {
                DDLogError("\(error)")
            }
        }
        */
    }
    //MARK: - ZPIMChatManagerDelegate
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
    //MARK: - UICollectionViewDataSource
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
