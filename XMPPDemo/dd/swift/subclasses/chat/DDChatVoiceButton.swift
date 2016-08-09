//
//  DDChatVoiceButton.swift
//  Dong
//
//  Created by darkdong on 15/10/30.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

class DDChatVoiceButton: DDButton {
    var voiceView: UIImageView!
    var voiceDuration: CGFloat = 1

    override var frame: CGRect {
        didSet {
            voiceView?.frame = frame.rectByEdgeInsets(voiceViewInsets)
        }
    }
    
    var voiceViewInsets: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            voiceView?.frame = frame.rectByEdgeInsets(voiceViewInsets)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let voiceViewFrame = frame.rectByEdgeInsets(voiceViewInsets)
        voiceView = UIImageView(frame: voiceViewFrame)
        voiceView.animationDuration = 1
        self.addSubview(voiceView)
    }
    
    func setVoice(isPlaying: Bool, style: DDChatVoiceBubbleStyle!, isMe: Bool) {
        setBackgroundImage(style.bubbleImage, forState: .Normal)
        setBackgroundImage(style.bubbleHighlightedImage, forState: .Highlighted)
        voiceViewInsets = style.bubbleInsets

        voiceView.image = style.voiceImage
        voiceView.animationImages = style.voiceAnimationImages
        voiceView.contentMode = isMe ? .Right : .Left
        if isPlaying {
            voiceView.startAnimating()
        }else {
            voiceView.stopAnimating()
        }
    }
}