//
//  DDChatController.swift
//  Dong
//
//  Created by darkdong on 15/1/22.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDChatController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var chatModels: [DDChatModel]!
    var screenFrame: CGRect!
    var tableView: UITableView!
    var inputBar: DDInputBar!
    
    deinit {
        DDLog2.print("DDChatController deinit")
    }
    
    override func loadView() {
        let keyboardView = DDKeyboardView(frame: UIScreen.mainScreen().bounds)
        keyboardView.shouldOffsetContentWhenKeyboardShow = false
        self.view = keyboardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLog2.print("DDChatController view \(self.view)")
        
        self.chatModels = []
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.title = "聊天"
        self.view.backgroundColor = UIColor(white: 235 / 255, alpha: 1)
        
        self.screenFrame = self.view.bounds

        let inputBarHeight = DDInputBar.minHeight
        let tableView = UITableView(frame: self.view.bounds)
        self.tableView = tableView
        tableView.contentInset = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: inputBarHeight, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.backgroundColor = self.view.backgroundColor
        tableView.separatorStyle = .None
        tableView.registerClass(DDChatTextCell.self, forCellReuseIdentifier: DDChatTextModel.reusableCellIdentifier)
        tableView.registerClass(DDChatVoiceCell.self, forCellReuseIdentifier: DDChatVoiceModel.reusableCellIdentifier)
        tableView.registerClass(DDChatImageCell.self, forCellReuseIdentifier: DDChatImageModel.reusableCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        let keyboardView = self.view as! DDKeyboardView
        tableView.addGestureRecognizer(keyboardView.panGestureToDismissKeyboard)
        
        self.view.addSubview(tableView)
        
        let inputBarFrame = CGRect(x: 0, y: screenFrame.maxY - inputBarHeight, width: self.view.width, height: inputBarHeight)
        let inputBar = DDInputBar(frame: inputBarFrame)
        self.inputBar = inputBar
        inputBar.vc = self
        inputBar.inputTextView.shouldChangeHeightAutomatically = true
        inputBar.inputTextViewDeltaHeightHandler = { [weak self] deltaHeight in
            self?.handleTextViewDeltaHeight(deltaHeight)
        }
        inputBar.inputModeDidChangeHandler = { [weak self] isVoice in
            self?.handleInputModeDidChange(isVoice)
        }
        self.view.addSubview(inputBar)
        
        //config keyboard view when table view and inut bar are both created
        keyboardView.additionalSpacing = inputBar.inputViewInset.bottom
        keyboardView.keyboardWillShowHandler = { [weak self] (view) -> Void in
            self?.handleKeyboardWillShow()
        }
        
        keyboardView.keyboardWillHideHandler = { [weak self] (view) -> Void in
            self?.handleKeyboardWillHide()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - cell action
    func voiceButtonClicked(button: DDBubbleVoiceButton!, model: DDChatVoiceModel!) {
        let imageView = button.contentView
        
        let player = DDPlayer.sharedPlayer
        
        if let voiceFileURL = model.fileURL {
            player.itemURL = voiceFileURL
        }
        player.play(fromStart: true)
        player.playEndHandler = {
            if let voiceFileURL = model.fileURL where voiceFileURL == player.itemURL {
                imageView.stopAnimating()
            }
        }
        let startAnimating = player.isPlaying
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if startAnimating {
                imageView.startAnimating()
            }else {
                imageView.stopAnimating()
            }
        })
    }
    
    func imageButtonClicked(button: DDBubbleImageButton!, model: DDChatImageModel!) {
        
    }

    func textButtonClicked(button: DDBubbleTextButton!, model: DDChatTextModel!) {
        
    }
    
    //MARK: - public
    func appendTextChat(text: String!, isMe: Bool) {
        let newTextModel = DDChatTextModel.createTextModel(text: text, isMe: isMe)
        newTextModel.calculateHeight()
        var models = self.chatModels
        models.append(newTextModel)
        self.chatModels = models
        self.tableView?.reloadData()
    }
    
    func appendImageChat(image: UIImage!, isMe: Bool) {
        let newImageModel = DDChatImageModel.createImageModel(image: image, isMe: isMe)
        newImageModel.calculateHeight()
        var models = self.chatModels
        models.append(newImageModel)
        self.chatModels = models
        self.tableView?.reloadData()
    }
    
    func appendVoiceChat(fileURL: NSURL!, duration: NSTimeInterval, isMe: Bool) {
        let newVoiceModel = DDChatVoiceModel.createVoiceModel(fileURL: fileURL, duration: duration, isMe: isMe)
        newVoiceModel.calculateHeight()
        var models = self.chatModels
        models.append(newVoiceModel)
        self.chatModels = models
        self.tableView?.reloadData()
    }
    
    //MARK: - private
    
    func handleTextViewDeltaHeight(deltaHeight: CGFloat) {
        var inset = self.tableView.contentInset
        inset.bottom += deltaHeight
        self.tableView.contentInset = inset
        self.tableView.scrollIndicatorInsets = inset
        self.tableView.scrollToBottomAnimated(false)
    }
    
    func handleInputModeDidChange(isVoice: Bool) {
        if isVoice {
            //input bar is at bottom with text mode, then switch to voice
            let inset = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: self.inputBar.height, right: 0)
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = inset
            self.tableView.scrollToBottomAnimated(false)
        }
    }
    func handleKeyboardWillShow() {
        let deltaY = (self.view as! DDKeyboardView).deltaY
        self.inputBar.bottom = self.screenFrame.maxY + deltaY
        var inset = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: self.inputBar.height, right: 0)
        inset.bottom += -deltaY
        self.tableView.contentInset = inset
        self.tableView.scrollIndicatorInsets = inset
        self.tableView.scrollToBottomAnimated(false)
    }
    
    func handleKeyboardWillHide() {
        self.inputBar.resetKeyboardInput()
        self.inputBar.bottom = self.screenFrame.maxY
        
        let inset = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: self.inputBar.height, right: 0)
        self.tableView.contentInset = inset
        self.tableView.scrollIndicatorInsets = inset
        self.tableView.scrollToBottomAnimated(false)
    }
    
    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.chatModels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = self.chatModels[indexPath.row]
        let reusableCellIdentifier = model.dynamicType.reusableCellIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath) as! DDChatCell
        cell.setupWithModel(model)
        
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let model = self.chatModels[index]
        return model.cellHeight
    }
}
