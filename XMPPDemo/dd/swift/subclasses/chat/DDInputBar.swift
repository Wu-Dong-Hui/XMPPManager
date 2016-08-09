//
//  DDInputBar.swift
//  Dong
//
//  Created by darkdong on 15/1/26.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
@objc enum DDInputMode: Int {
    case Text = 0
    case Voice
    case More
    case Emotion
}
class DDInputBar: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static var log: DDLog2 = {
        let log = DDLog2()
        log.enabled = false
        return log
    }()
    class var minHeight: CGFloat {
        return 50
    }
    
    weak var vc: UIViewController!

    //bar
    var minFrame: CGRect!
    var customKeyboardHeight: CGFloat {
        return 200
    }
    
    //input text or voice
    var inputTextView: DDInputTextView!
    var inputVoiceView: DDInputVoiceView!
    var inputViewInset: UIEdgeInsets {
        let margin = (DDInputBar.minHeight - DDInputTextView.suggestedBarHeight) / 2
        //margin = (50 - 44) / 2 = 3
        return UIEdgeInsets(top: margin, left: 40, bottom: margin, right: 40)
    }
    
    //toggle input mode
    var inputModeButton: DDButton!
    var inputModeButtonFrame: CGRect {
        return CGRect(x: 0, y: 5, width: 40, height: 40)
    }
    
    //input emotion
    var inputEmotionButton: DDButton!
    var inputEmotionButtonFrame: CGRect {
        let length: CGFloat = 40
        return CGRect(x: width - 2 * length, y: 5, width: length, height: length)
    }
    private var inputEmotionView: UIView!
    var lazyInputEmotionView: UIView! {
        if inputEmotionView == nil {
            inputEmotionView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: customKeyboardHeight))
            inputEmotionView.backgroundColor = backgroundColor
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5))
            topLine.backgroundColor = UIColor(ir: 212, ig: 212, ib: 212)
            topLine.autoresizingMask = .FlexibleWidth
            inputEmotionView.addSubview(topLine)
        }
        return inputEmotionView
    }
    
    //input more
    var inputMoreButton: DDButton!
    var inputMoreButtonFrame: CGRect {
        let length: CGFloat = 40
        return CGRect(x: width - length, y: 5, width: length, height: length)
    }
    private var inputMoreView: UIView!
    var lazyInputMoreView: UIView! {
        if inputMoreView == nil {
            inputMoreView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: customKeyboardHeight))
            inputMoreView.backgroundColor = backgroundColor
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 0.5))
            topLine.backgroundColor = UIColor(ir: 212, ig: 212, ib: 212)
            topLine.autoresizingMask = .FlexibleWidth
            inputMoreView.addSubview(topLine)
            
            let buttonSize = CGSize(width: 59, height: 59)
            let picBtn = DDButton(frame: CGRect(origin: CGPoint(x: 10, y: 10), size: buttonSize))
            picBtn.setBackgroundImage(UIImage(namedNoCache: "DDInput.bundle/bg_input_more_normal"), forState: .Normal)
            picBtn.setBackgroundImage(UIImage(namedNoCache: "DDInput.bundle/bg_input_more_highlighted"), forState: .Highlighted)
            picBtn.setImage(UIImage(namedNoCache: "DDInput.bundle/input_more_pic"), forState: .Normal)
            picBtn.touchUpInsideHandler = { [weak self] button in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                self?.viewController?.presentViewController(imagePicker, animated: true, completion: nil)
                return
            }
            inputMoreView.addSubview(picBtn)
            
            let cameraBtn = DDButton(frame: CGRect(origin: CGPoint(x: picBtn.right + 10, y: 10), size: buttonSize))
            cameraBtn.setBackgroundImage(UIImage(namedNoCache: "DDInput.bundle/bg_input_more_normal"), forState: .Normal)
            cameraBtn.setBackgroundImage(UIImage(namedNoCache: "DDInput.bundle/bg_input_more_highlighted"), forState: .Highlighted)
            cameraBtn.setImage(UIImage(namedNoCache: "DDInput.bundle/input_more_camera"), forState: .Normal)
            cameraBtn.touchUpInsideHandler = { [weak self] button in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera
                self?.viewController?.presentViewController(imagePicker, animated: true, completion: nil)
                return
            }
            inputMoreView.addSubview(cameraBtn)
        }
        return inputMoreView
    }
    
    //record voice
    var recorder: AVAudioRecorder!
    var minVoiceDuration: NSTimeInterval = 1
    let queueForWave2Mp3 = dispatch_queue_create(nil,  DISPATCH_QUEUE_SERIAL)
    var waveFileURL: NSURL!
    var mp3FileURL: NSURL!
    var recordingVoiceHelperView: DDRecordingVoiceHelperView?
    var timerForUpdateLevel: DDDisplayLink?
    
    //callback handler
    var inputModeDidChangeHandler: ((Bool) -> Void)?
    var inputModeDidChangeHandler2: ((DDInputMode) -> Void)?
    var inputTextViewDeltaHeightHandler: ((CGFloat) -> Void)?
    var inputTextDidFinishHandler: ((String?) -> Void)?
    var inputImageDidFinishHandler: ((UIImage?) -> Void)?
    var inputVoiceDidFinishHandler: ((NSURL?, NSTimeInterval) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DDInputBar.log.print("DDInputBar init \(self)")

        minFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: self.dynamicType.minHeight)

        backgroundColor = UIColor(ir: 244, ig: 244, ib: 246)
        
        let topLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
        topLine.backgroundColor = UIColor(ir: 195, ig: 195, ib: 197)
        topLine.autoresizingMask = .FlexibleWidth
        addSubview(topLine)
        
        //setup input text and voice view
        let inputViewFrame = minFrame.rectByEdgeInsets(inputViewInset)
        
        inputVoiceView = DDInputVoiceView(frame: inputViewFrame)
        inputVoiceView.hidden = true
        inputVoiceView.startRecordingHandler = { [weak self] in
            self?.startRecordingVoice()
        }
        inputVoiceView.stopRecordingHandler = { [weak self] cancelling in
            self?.stopRecordingVoice(cancelling)
        }
        inputVoiceView.cancelRecordingHandler = { [weak self] cancelling in
            self?.recordingVoiceHelperView?.setupWithCancelling(cancelling)
        }
        addSubview(inputVoiceView)
        
        recordingVoiceHelperView = DDRecordingVoiceHelperView(frame: CGRect(origin: CGPointZero, size: CGSize(width: DDSystem.x(140), height: DDSystem.x(140))))
        
        inputTextView = DDInputTextView(frame: inputViewFrame)
        inputTextView.setDefaults()
        inputTextView.didDeltaHeightHandler = { [weak self] deltaHeight in
            self?.handleInputTextViewDeltaHeight(deltaHeight)
        }
        inputTextView.didFinishHandler = { [weak self] inputTextView in
            let text = inputTextView.text
            inputTextView.text = nil
            self?.handleInputTextViewDidFinish(text)
        }
        addSubview(inputTextView)
        
        inputModeButton = DDButton(frame: inputModeButtonFrame)
        inputModeButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_voice_normal"), forState: .Normal)
        inputModeButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_voice_highlighted"), forState: .Highlighted)
        inputModeButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_text_normal"), forState: .Selected)
        inputModeButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_text_highlighted"), forState: [.Selected, .Highlighted])
        inputModeButton.touchUpInsideHandler = { [weak self] button in
            self?.handleInputModeButtonClicked()
        }
        addSubview(inputModeButton)

        inputMoreButton = DDButton(frame: inputMoreButtonFrame)
        inputMoreButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_more_normal"), forState: .Normal)
        inputMoreButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_more_highlighted"), forState: .Highlighted)
        inputMoreButton.touchUpInsideHandler = { [weak self] button in
            DDInputBar.log.print("inputMore")
            self?.handleInputMoreButtonClicked()
        }
        addSubview(inputMoreButton)
        
//        inputEmotionButton = DDButton(frame: inputEmotionButtonFrame)
//        inputEmotionButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_emotion_normal"), forState: .Normal)
//        inputEmotionButton.setImage(UIImage(namedNoCache: "DDInput.bundle/input_emotion_highlighted"), forState: .Highlighted)
//        inputEmotionButton.touchUpInsideHandler = { [weak self] button in
//            DDInputBar.log.print("inputEmotion")
//            self?.handleInputEmotionButtonClicked()
//        }
//        addSubview(inputEmotionButton)
    }
    
    deinit {
        DDInputBar.log.print("DDInputBar deinit \(self)")
        recordingVoiceHelperView?.removeFromSuperview()
        timerForUpdateLevel?.invalidate()
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        DDInputBar.log.print("didFinishPickingMediaWithInfo \(info)")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        inputImageDidFinishHandler?(image)
        viewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        inputImageDidFinishHandler?(nil)
        viewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - public methods
    func resetGeometry() {
        setHeightWhileKeepingBottom(minFrame.height)
        
        let inputViewFrame = minFrame.rectByEdgeInsets(inputViewInset)
        inputTextView.frame = inputViewFrame
        inputVoiceView.frame = inputViewFrame
        
        inputModeButton.frame = inputModeButtonFrame
        inputEmotionButton?.frame = inputEmotionButtonFrame
        inputMoreButton.frame = inputMoreButtonFrame
    }
    
    func resetKeyboardInput() {
        inputMoreButton.selected = false
        inputEmotionButton?.selected = false
        inputTextView.textView.inputView = nil
    }
    
    //MARK: - private methods
    /*
    func setInputMode(isVoiceMode: Bool) {
        inputTextView.hidden = isVoiceMode
        inputVoiceView.hidden = !inputTextView.hidden
        inputModeButton.selected = isVoiceMode
        
        if isVoiceMode {
            DDInputBar.log.print("toggle input mode to voice")
            resetGeometry()
            endEditing(true)
        }else {
            DDInputBar.log.print("toggle input mode to text")
            inputTextView.adjustTextView(inputTextView.textView)
            inputTextView.becomeFirstResponder()
        }
        
        //call external handler
        inputModeDidChangeHandler?(isVoiceMode)
    }
    */
    func settingInputMode(mode: DDInputMode) {
        switch mode {
        case .Text:
            inputTextView.hidden = false
            inputVoiceView.hidden = true
            inputModeButton.selected = false
            inputMoreButton.selected = false
            replaceKeyboardInputView(nil)
            inputTextView.adjustTextView(inputTextView.textView)
            inputTextView.becomeFirstResponder()
            break
        case .Voice:
            inputTextView.hidden = true
            inputVoiceView.hidden = false
            inputModeButton.selected = true
            inputMoreButton.selected = false
            resetGeometry()
            endEditing(true)
            break
        case .More:
            inputVoiceView.hidden = true
            inputTextView.hidden = false
            replaceKeyboardInputView(lazyInputMoreView)
            break
        case .Emotion:
            break
        }
        inputModeDidChangeHandler2?(mode)
    }
    func handleInputModeButtonClicked() {
        let isVoiceMode = !inputModeButton.selected
//        setInputMode(isVoiceMode)
        if isVoiceMode {
            settingInputMode(.Voice)
        } else {
            settingInputMode(.Text)
        }
    }
    
    func handleInputMoreButtonClicked() {
        inputEmotionButton?.selected = false

        let selected = !inputMoreButton.selected
        inputMoreButton.selected = selected
        if selected {
            DDInputBar.log.print("set more keyboard")
//            setInputMode(false)
//            replaceKeyboardInputView(lazyInputMoreView)
            settingInputMode(.More)
        }else {
            DDInputBar.log.print("set standard keyboard")
//            replaceKeyboardInputView(nil)
//            inputTextView.becomeFirstResponder()
            settingInputMode(.Text)
        }
    }
    
    func handleInputEmotionButtonClicked() {
        inputMoreButton.selected = false

        let selected = !inputEmotionButton.selected
        inputEmotionButton.selected = selected
        if selected {
            DDInputBar.log.print("set emotion keyboard")
//            setInputMode(false)
            settingInputMode(.Emotion)
            replaceKeyboardInputView(lazyInputEmotionView)
        }else {
            DDInputBar.log.print("set standard keyboard")
            replaceKeyboardInputView(nil)
        }
    }
    
    func handleInputTextViewDeltaHeight(deltaHeight: CGFloat) {
        setHeightWhileKeepingBottom(height + deltaHeight)
        inputModeButton.top += deltaHeight
        inputEmotionButton?.top += deltaHeight
        inputMoreButton.top += deltaHeight
        
        //call external handler
        inputTextViewDeltaHeightHandler?(deltaHeight)
    }
    
    func handleInputTextViewDidFinish(text: String?) {
        let deltaHeight = minFrame.height - height
        inputTextViewDeltaHeightHandler?(deltaHeight)
        resetGeometry()
        inputTextDidFinishHandler?(text)
    }
    
    func replaceKeyboardInputView(inputView: UIView!) {
        DDInputBar.log.print("replaceWithKeyboardInputView \(inputView)")
        
        if inputView != nil {
            if !inputTextView.isFirstResponder() {
                inputTextView.becomeFirstResponder()
            }
        }
        
        inputTextView.textView.inputView = inputView
        
        let windows = UIApplication.sharedApplication().windows
        if windows.count > 1 {
            let keyboardWindow = UIApplication.sharedApplication().windows[1]
            UIView.transitionWithView(keyboardWindow, duration: 0.25, options: .TransitionCrossDissolve, animations: { [weak self] () -> Void in
                self?.inputTextView.textView.reloadInputViews()
                return
                }) { (finished) -> Void in
            }
            return
        }
        inputTextView.textView.reloadInputViews()
    }
    
    func startRecordingVoice() {
        DDInputBar.log.print("startRecordingVoice")
        
        do {
            try AVAudioSession.sharedInstance().setActive(true, withOptions: .NotifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
            
            let fileBaseName = NSUUID().UUIDString
            let waveFileName = "\(fileBaseName).wav"
            let mp3FileName = "\(fileBaseName).mp3"
            waveFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(waveFileName)
            mp3FileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(mp3FileName)
            
            let settings: [String: AnyObject] = [
                AVFormatIDKey : Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 8000,
                AVNumberOfChannelsKey: 1,
            ]
            
            recorder = try AVAudioRecorder(URL: waveFileURL, settings: settings)
            if recorder.record() {
                recorder.meteringEnabled = true
                recordingVoiceHelperView?.hidden = false
                timerForUpdateLevel?.invalidate()
                timerForUpdateLevel = DDDisplayLink(scheduleWithHandler: { [weak self] (dl) -> Void in
                    if let recorder = self?.recorder where recorder.recording {
                        self?.recordingVoiceHelperView?.updateMicLevel(recorder)
                    }
                    })
                timerForUpdateLevel?.displayLink.frameInterval = 2
            }
        }catch {
            DDLog2.print("startRecordingVoice error \(error)")
        }
    }
    
    func stopRecordingVoice(cancelling: Bool) {
        DDInputBar.log.print("stopRecordingVoice cancelling \(cancelling)")
        let voiceDuration = recorder.currentTime
        recorder.stop()
        recordingVoiceHelperView?.hidden = true
        timerForUpdateLevel?.invalidate()
        
        if cancelling || voiceDuration < minVoiceDuration {
            //cancel or voice duration is too short, ignore it
            DDInputBar.log.print("cancel recording")
            recorder.deleteRecording()
        }else {
            DDInputBar.log.print("convert wave file to mp3")
            convertWaveToMp3(recorder.url, completion: { [weak self] () -> Void in
                if let mp3FilePath = self?.mp3FileURL.path where NSFileManager.defaultManager().fileExistsAtPath(mp3FilePath) {
                    self?.inputVoiceDidFinishHandler?(self?.mp3FileURL, voiceDuration)
                }else {
                    self?.inputVoiceDidFinishHandler?(nil, 0)
                }
            })
        }
    }
    
    func convertWaveToMp3(waveFileURL: NSURL!, completion: (() -> Void)!) {
        let mp3FileURL = self.mp3FileURL
        dispatch_async(queueForWave2Mp3) { () -> Void in
            if let waveData = ddAudioDataFromFileURL(waveFileURL) {
                ddWriteWaveData(waveData, toMp3File: mp3FileURL)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    completion?()
                }
            }
        }
    }
}

//MARK: - functions

private func ddAudioDataFromFileURL(fileURL: NSURL!) -> NSData! {
//    let waveFileData = NSData(contentsOfURL: fileURL)!
//    DDLog2.print("waveFileData \(waveFileData.length)")
//    
//    let waveFileHeaderLength = 4096
//    let waveDataRange = NSMakeRange(waveFileHeaderLength, waveFileData.length - waveFileHeaderLength)
//    let waveData = waveFileData.subdataWithRange(waveDataRange)
//    
//    DDLog2.print("waveFileData \(waveFileData.length) waveData \(waveData.length)")
//    return waveData
    
    var fileRef: ExtAudioFileRef = nil
    
    readAudioData: repeat {
        var status: OSStatus
        
        status = ExtAudioFileOpenURL(fileURL, &fileRef)
        if status != noErr {
            DDInputBar.log.log("open audio file fail")
            break
        }
        
        var inputFormat = AudioStreamBasicDescription(mSampleRate: 0, mFormatID: 0, mFormatFlags: 0, mBytesPerPacket: 0, mFramesPerPacket: 0, mBytesPerFrame: 0, mChannelsPerFrame: 0, mBitsPerChannel: 0, mReserved: 0)
        var propertySize = UInt32(sizeof(AudioStreamBasicDescription))
        
        status = ExtAudioFileGetProperty(fileRef, ExtAudioFilePropertyID(kExtAudioFileProperty_FileDataFormat), &propertySize, &inputFormat)
        if status != noErr {
            DDInputBar.log.log("get property kExtAudioFileProperty_FileDataFormat fail")
            break
        }
        
        DDInputBar.log.log("audio file input format \(inputFormat.mSampleRate) \(inputFormat.mFormatID) mBytesPerPacket \(inputFormat.mBytesPerPacket) mFramesPerPacket \(inputFormat.mFramesPerPacket) mBytesPerFrame \(inputFormat.mBytesPerFrame) mChannelsPerFrame \(inputFormat.mChannelsPerFrame) mBitsPerChannel \(inputFormat.mBitsPerChannel)")
        
        var outputFormat = inputFormat
        propertySize = UInt32(sizeof(AudioStreamBasicDescription))
        status = ExtAudioFileSetProperty(fileRef, ExtAudioFilePropertyID(kExtAudioFileProperty_ClientDataFormat), propertySize, &outputFormat)
        if status != noErr {
            DDInputBar.log.log("set property kExtAudioFileProperty_ClientDataFormat fail")
            break
        }
        
        var frameCount: Int64 = 0
        propertySize = UInt32(sizeof(Int64))
        status = ExtAudioFileGetProperty(fileRef, ExtAudioFilePropertyID(kExtAudioFileProperty_FileLengthFrames), &propertySize, &frameCount)
        if status != noErr {
            DDInputBar.log.log("get property kExtAudioFileProperty_FileLengthFrames fail")
            break
        }
        
        DDInputBar.log.log("total frames \(frameCount)")
        
        let dataSize = Int(frameCount) * Int(outputFormat.mBytesPerFrame)
        if let data = NSMutableData(length: dataSize) {
            let buffer = AudioBuffer(mNumberChannels: outputFormat.mChannelsPerFrame, mDataByteSize: UInt32(dataSize), mData: data.mutableBytes)
            var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: buffer)
            var frameCountUInt32 = UInt32(frameCount)
            status = ExtAudioFileRead(fileRef, &frameCountUInt32, &bufferList)
            if status == noErr {
                DDInputBar.log.log("read audio data success")
                ExtAudioFileDispose(fileRef)
                return data
            }
        }
    }while(false)
    
    if fileRef != nil {
        ExtAudioFileDispose(fileRef)
    }
    
    return nil
}

private func ddWriteWaveData(waveData: NSData!, toMp3File mp3FileURL: NSURL!) {
    DDInputBar.log.print("ddWriteWaveData length \(waveData.length)")
    if waveData.length == 0 {
        return
    }
    
    //USE_LAME should be defined in XCode -> Build Settings -> Other Swift Flags -> -DUSE_LAME
    #if !arch(i386) && !arch(x86_64) && os(iOS) && USE_LAME
        let lameGlobalFlags = lame_init()
        //解码必需的参数
        lame_set_num_channels(lameGlobalFlags, 1)
        lame_set_in_samplerate(lameGlobalFlags, 8000)
        lame_set_out_samplerate(lameGlobalFlags, 8000)
        //影响音质的参数
        lame_set_VBR(lameGlobalFlags, vbr_default)
        lame_set_quality(lameGlobalFlags, 7)
        
        lame_init_params(lameGlobalFlags)
        
        let waveBuffer = UnsafePointer<Int16>(waveData.bytes)
        let samplesPerChannel = waveData.length / 2
        let mp3BufferSize = waveData.length
        let mp3Buffer = UnsafeMutablePointer<UInt8>.alloc(mp3BufferSize)
        
        let mp3Frames = lame_encode_buffer(lameGlobalFlags, waveBuffer, nil, Int32(samplesPerChannel), mp3Buffer, Int32(mp3BufferSize))
        let mp3Data = NSData(bytes: mp3Buffer, length: Int(mp3Frames))
        
        let lastMp3Frames = lame_encode_flush(lameGlobalFlags, mp3Buffer, Int32(mp3BufferSize))
        let lastMp3Data = NSData(bytes: mp3Buffer, length: Int(lastMp3Frames))
        
        mp3Buffer.destroy()
        lame_close(lameGlobalFlags)
        
        DDInputBar.log.log("mp3Frames \(mp3Frames) lastMp3Frames \(lastMp3Frames)")
        
        let totalMp3Data = mp3Data + lastMp3Data
        totalMp3Data.writeToURL(mp3FileURL, atomically: true)
        
    #endif
}

class DDRecordingVoiceHelperView: UIView {
    static var micImage: UIImage! = {
        return UIImage(namedNoCache:"DDInput.bundle/recording_mic")
    }()

    static var cancelImage: UIImage! = {
        return UIImage(namedNoCache:"DDInput.bundle/recording_cancel")
    }()

    static var textForRecording: String! = {
        return "手指上划，取消发送"
    }()
    
    static var textForCancelling: String! = {
        return "松开手指，取消发送"
    }()

    var micView: UIImageView!
    var levelView: DDLineLevelView!
    var cancelView: UIImageView!
    var tips: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let window = UIApplication.sharedApplication().keyWindow {
            center = window.centerOfSize
            backgroundColor = UIColor(white: 0.5, alpha: 0.8)
            hidden = true
            clipsToRoundedRect(cornerRadius: 6)
            
            let margin = DDSystem.x(10)
            let tipsHeight: CGFloat = 24
            let viewHeight = frame.height - tipsHeight - 3 * margin
                
            micView = UIImageView(frame: CGRect(x: margin, y: margin, width: frame.width / 2 - margin, height: viewHeight))
            micView.contentMode = .ScaleAspectFill
            micView.clipsToBounds = true
            micView.image = DDRecordingVoiceHelperView.micImage
            addSubview(micView)

            levelView = DDLineLevelView(frame: CGRect(x: frame.width / 2, y: margin, width: frame.width / 2 - margin, height: viewHeight))
            levelView.contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 20, right: 10)
            levelView.maxLevels = 8
            levelView.currentLevels = 1
            let firstLine = DDLine(startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0.2, y: 1))
            let lastLine = DDLine(startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.6, y: 0))
            levelView.generateLinesByInterpolation(firstLine: firstLine, lastLine: lastLine)
            addSubview(levelView)

            cancelView = UIImageView(frame: CGRect(x: margin, y: margin, width: frame.width - 2 * margin, height: viewHeight))
            cancelView.contentMode = .ScaleAspectFill
            cancelView.clipsToBounds = true
            cancelView.image = DDRecordingVoiceHelperView.cancelImage
            addSubview(cancelView)

            tips = UILabel(frame: CGRect(x: margin, y: frame.height - margin - tipsHeight, width: frame.width - 2 * margin, height: tipsHeight))
            tips.textColor = UIColor.whiteColor()
            tips.font = UIFont.systemFontOfSize(14)
//            tips.textAlignment = .Center
            tips.adjustsFontSizeToFitWidth = true
            tips.clipsToRoundedRect(cornerRadius: 3)
            addSubview(tips)

            window.addSubview(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWithCancelling(cancelling: Bool) {
        if cancelling {
            micView.hidden = true
            levelView.hidden = true
            cancelView.hidden = false
            tips.text = DDRecordingVoiceHelperView.textForCancelling
            tips.backgroundColor = UIColor(ir: 150, ig: 50, ib: 50)
        }else {
            micView.hidden = false
            levelView.hidden = false
            cancelView.hidden = true
            tips.text = DDRecordingVoiceHelperView.textForRecording
            tips.backgroundColor = nil
        }
    }
    
    func updateMicLevel(recorder: AVAudioRecorder) {
        recorder.updateMeters()
        var power = recorder.peakPowerForChannel(0)
        
        //let -60 as lowest power indeed, though the lowest power is -160 in theory
        let minPower: Float = -60
        //let 0 as highest power
        let maxPower: Float = 0

        if power < minPower {
            power = minPower
        }
        if power > maxPower {
            power = maxPower
        }
        
        let levelPercent = DDMath.similarY(x1: minPower, x: power, x2: maxPower, y1: 0, y2: 1)
        let level = Int(round(Float(levelView.maxLevels - 1) * levelPercent)) + 1
//        DDLog2.print("power \(power) levelPercent \(levelPercent) level \(level)")
        
        levelView.currentLevels = level
    }
}