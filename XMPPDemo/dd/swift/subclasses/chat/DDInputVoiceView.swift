//
//  DDInputVoiceView.swift
//  Dong
//
//  Created by darkdong on 15/3/12.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

let DDNotificationNameInputVoiceViewTouchesBegan = "DDNotificationNameInputVoiceViewTouchesBegan"
let DDNotificationInfoKeyEvent = "event"

class DDInputVoiceView: UIImageView {
    static var backgroundImage: UIImage! = {
        return UIImage(namedNoCache: "DDInput.bundle/bg_input_voice")?.resizableImage()
    }()
    
    static var backgroundHighlightedImage: UIImage! = {
        return UIImage(namedNoCache:"DDInput.bundle/bg_input_voice_highlighted")?.resizableImage()
    }()

    static var textForNormalState: String! = {
        return "按住 说话"
    }()
    
    static var textForHighlightedState: String! = {
        return "松开 结束"
    }()
    
    var textLabel: UILabel!
    override var highlighted: Bool {
        didSet {
            if highlighted {
                textLabel?.text = DDInputVoiceView.textForHighlightedState
            }else {
                textLabel?.text = DDInputVoiceView.textForNormalState
            }
        }
    }
    
    var recording = false {
        didSet {
            highlighted = recording
        }
    }
    
    var cancelling = true {
        didSet {
            if cancelling != oldValue {
                cancelRecordingHandler?(cancelling)
            }
        }
    }
    
    var startRecordingHandler: (() -> Void)?
    var stopRecordingHandler: ((Bool) -> Void)?
    var cancelRecordingHandler: ((Bool) -> Void)?

    var touchesBeganObserver: NSObjectProtocol?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DDLog2.log("DDInputVoiceView init \(self)")
        userInteractionEnabled = true
//        backgroundColor = UIColor.greenColor()
        
        image = DDInputVoiceView.backgroundImage
        highlightedImage = DDInputVoiceView.backgroundHighlightedImage
        
        textLabel = UILabel(frame: bounds)
        textLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        textLabel.text = DDInputVoiceView.textForNormalState
        textLabel.textAlignment = .Center
        addSubview(textLabel)
        
        touchesBeganObserver = NSNotificationCenter.defaultCenter().addObserverForName(DDNotificationNameInputVoiceViewTouchesBegan, object: self, queue: nil) { [weak self] (notification) -> Void in
            if let info = notification.userInfo as? [String: AnyObject], event = info[DDNotificationInfoKeyEvent] as? UIEvent, touches = event.allTouches() {
                self?.touchesBegan(touches, withEvent: event)
            }
        }
    }
    
    deinit {
        DDLog2.log("DDInputVoiceView deinit \(self)")

        if let observer = touchesBeganObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    //MARK: - UIResponder
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        DDLog2.log("DDInputVoiceView touchesBegan \(self) userInteractionEnabled \(self.userInteractionEnabled)")
        if !recording {
            startRecordingHandler?()
            recording = true
            cancelling = false
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        DDLog2.log("DDInputVoiceView touchesEnded cancelling \(cancelling)")
        if recording {
            stopRecordingHandler?(cancelling)
            recording = false
            cancelling = false
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
//        DDLog2.log("DDInputVoiceView touchesMoved cancelling \(cancelling)")
        if recording, let touch = touches.first {
            let location = touch.locationInView(self)
            cancelling = !bounds.contains(location)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        DDLog2.log("DDInputVoiceView touchesCancelled \(event)")
        if recording {
            stopRecordingHandler?(cancelling)
            recording = false
            cancelling = false
        }
    }
    //MARK: - private
}