//
//  DDChat2Controller.swift
//  Dong
//
//  Created by darkdong on 15/10/28.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

class DDChat2Controller: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var models = [DDChat2Model]()
    var collectionView: UICollectionView!
    var inputBar: DDInputBar!
    var keyboardObserver: DDKeyboardObserver!
    var contentInsetsWithoutKeyboard = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: DDInputBar.minHeight, right: 0)

    deinit {
        DDLog2.print("DDChat2Controller deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        setCollectionViewContentInsets(contentInsetsWithoutKeyboard)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(DDChat2TextModel.cellClass, forCellWithReuseIdentifier: DDChat2TextModel.cellReuseIdentifier)
        collectionView.registerClass(DDChat2ImageModel.cellClass, forCellWithReuseIdentifier: DDChat2ImageModel.cellReuseIdentifier)
        collectionView.registerClass(DDChat2VoiceModel.cellClass, forCellWithReuseIdentifier: DDChat2VoiceModel.cellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        let inputBarHeight = DDInputBar.minHeight
        let inputBarFrame = CGRect(x: 0, y: view.height - inputBarHeight, width: view.width, height: inputBarHeight)
        inputBar = DDInputBar(frame: inputBarFrame)
        DDLog2.print("inputBar \(inputBar) view.height \(view.height)")
        inputBar.inputTextView.shouldChangeHeightAutomatically = true
        inputBar.inputTextViewDeltaHeightHandler = { [weak self] deltaHeight in
            self?.handleInputBarDeltaHeight(deltaHeight)
        }
//        inputBar.inputModeDidChangeHandler = { [weak self] isVoice in
//            self?.handleInputModeDidChange(isVoice)
//        }
        inputBar.inputModeDidChangeHandler2 = { [weak self] mode in
            self?.handleInputModeDidChanged(mode)
        }
        inputBar.inputTextDidFinishHandler = { [weak self] text in
            self?.sendChatText(text)
        }
        inputBar.inputImageDidFinishHandler = { [weak self] image in
            self?.sendChatImage(image)
        }
        inputBar.inputVoiceDidFinishHandler = { [weak self] (fileURL, duration) in
            self?.sendChatVoice(fileURL, duration: duration)
        }
        self.view.addSubview(inputBar)

        keyboardObserver = DDKeyboardObserver(containerView: view)
        keyboardObserver.shiftView = collectionView
        keyboardObserver.shouldShiftAutomatically = false
        keyboardObserver.keyboardWillShowHandler = { [weak self] (focusView, deltaY) -> Void in
            self?.handleKeyboardWillShow()
        }
        keyboardObserver.keyboardWillHideHandler = { [weak self] (focusView, deltaY) -> Void in
            self?.handleKeyboardWillHide()
        }
        
        /*
        let me = DDChatUser(identity: .Me)
        me.image = DDChatUser.maleImage
        
        let other = DDChatUser(identity: .Other)
        other.image = DDChatUser.femaleImage

        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(16)
//            NSForegroundColorAttributeName: UIColor.redColor()
        ]
        
        let attributedText1 = NSAttributedString(string: "测试test测试", attributes: attributes)
        let model1 = DDChat2TextModel(attributedText: attributedText1, user: me)
        models.append(model1)

        let attributedText2 = NSAttributedString(string: "测试test测试", attributes: attributes)
        let model2 = DDChat2TextModel(attributedText: attributedText2, user: other)
        models.append(model2)
        
        //icon_weibo_selected album_banner empty_pic
        let leftImage = UIImage(named: "DDChat.bundle/picture_left")!
        let rightImage = UIImage(named: "DDChat.bundle/picture_right")!

        let model3 = DDChat2ImageModel(image: leftImage, user: other)
        models.append(model3)
        
        let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("8k", ofType: "mp3")!)
        
        let model4 = DDChat2VoiceModel(fileURL: fileURL, duration: 1, user: me)
        models.append(model4)
        
        let model5 = DDChat2VoiceModel(fileURL: fileURL, duration: 6, user: other)
        models.append(model5)
        
        let attributedText6 = NSAttributedString(string: "didFailToRegisterForRemoteNotificationsWithError Error", attributes: attributes)
        let model6 = DDChat2TextModel(attributedText: attributedText6, user: other)
        models.append(model6)
        
        let model7 = DDChat2ImageModel(image: rightImage, user: me)
        models.append(model7)
        
        let model8 = DDChat2VoiceModel(fileURL: fileURL, duration: 10, user: other)
        models.append(model8)

        let attributedText9 = NSAttributedString(string: "记者从博罗县警方获悉，为缉拿该男子，警方悬赏金额已提高至20万元", attributes: attributes)
        let model9 = DDChat2TextModel(attributedText: attributedText9, user: me)
        models.append(model9)

        for model in models {
            model.calculateGeometry(true)
        }
*/
    }
    
    //MARK: - public
    func textButtonClicked(button: DDChatTextButton, model: DDChat2TextModel) {
        DDLog2.print("textButtonClicked")
        
    }
    
    func imageButtonClicked(button: DDChatImageButton, model: DDChat2ImageModel) {
        DDLog2.print("imageButtonClicked")

    }
    
    func voiceButtonClicked(button: DDChatVoiceButton, model: DDChat2VoiceModel) {
        DDLog2.print("voiceButtonClicked")
        let player = DDPlayer.sharedPlayer
        if let oldVoiceModel = player.object as? DDChat2VoiceModel where oldVoiceModel != model {
            DDLog2.print("stop old voice")
            oldVoiceModel.isPlaying = false
            player.reset()
        }
        player.object = model
        model.isPlaying = !model.isPlaying
        collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())

        let voiceFileURL = model.fileURL
        player.itemURL = voiceFileURL
        
        if model.isPlaying {
            player.play(fromStart: true)
        }else {
            player.pause()
        }
        player.playEndHandler = { [weak self] in
            DDLog2.print("play end")
            if voiceFileURL == DDPlayer.sharedPlayer.itemURL {
                DDLog2.print("reload data")
                model.isPlaying = false
                self?.collectionView.reloadData()
            }
        }
    }
    
    //MARK: - should override to do custom action

    func sendChatText(text: String?) {
    }

    func sendChatImage(image: UIImage?) {
    }
    
    func sendChatVoice(fileURL: NSURL?, duration: NSTimeInterval) {
    }
    
    //MARK: - private

    func handleInputBarDeltaHeight(deltaHeight: CGFloat) {
        DDLog2.print("handleInputBarDeltaHeight \(deltaHeight)")
        
        contentInsetsWithoutKeyboard.bottom += deltaHeight
        var insets = collectionView.contentInset
        insets.bottom += deltaHeight
        setCollectionViewContentInsets(insets)
        collectionView.scrollToBottomAnimated(false)
    }
    /*
    func handleInputModeDidChange(isVoice: Bool) {
        DDLog2.print("handleInputModeDidChange isVoice \(isVoice)")
        if isVoice {
            //input bar is at bottom with text mode, then switch to voice
            contentInsetsWithoutKeyboard = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: DDInputBar.minHeight, right: 0)
            setCollectionViewContentInsets(contentInsetsWithoutKeyboard)
        }else {
        }
    }
    */
    func handleInputModeDidChanged(mode: DDInputMode) {
        DDLog2.print("handleInputModeDidChange mode \(mode)")
        switch mode {
        case .Text:
            break
        case .Voice:
            contentInsetsWithoutKeyboard = UIEdgeInsets(top: DDSystem.topBarHeight, left: 0, bottom: DDInputBar.minHeight, right: 0)
            setCollectionViewContentInsets(contentInsetsWithoutKeyboard)
            break
        case .More:
            break
        case .Emotion:
            break
        }
        
    }
    func handleKeyboardWillShow() {
        guard let deltaY = keyboardObserver.deltaY else {
            return
        }

        DDLog2.print("handleKeyboardWillShow deltaY \(deltaY)")

        inputBar.bottom += deltaY

        var insets = collectionView.contentInset
        insets.bottom += -deltaY
        setCollectionViewContentInsets(insets)
        collectionView.scrollToBottomAnimated(false)
    }
    
    func handleKeyboardWillHide() {
        guard let deltaY = keyboardObserver.deltaY else {
            return
        }
        DDLog2.print("handleKeyboardWillHide deltaY \(deltaY)")

        inputBar.bottom = view.height
        inputBar.resetKeyboardInput()
        setCollectionViewContentInsets(contentInsetsWithoutKeyboard)
    }
    
    func setCollectionViewContentInsets(insets: UIEdgeInsets) {
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model = models[indexPath.row]
//        DDLog2.print("model \(model) cell \(model.dynamicType.cellReuseIdentifier)")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(model.dynamicType.cellReuseIdentifier, forIndexPath: indexPath) as! DDChat2Cell
        cell.reuseWithModel(model)
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let model = models[indexPath.row]
        return model.cellSize!
    }
}