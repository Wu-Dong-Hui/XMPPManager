//
//  DDChatCell.swift
//  Dong
//
//  Created by darkdong on 15/1/19.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit
import AVFoundation

class DDChatCell: UITableViewCell {
    static var avatarDimension = DDSystem.x(44)
    static var avatarSize = CGSize(width: avatarDimension, height: avatarDimension)
    static var margin = DDSystem.x(10)
    static var spacingBetweenBubbleAndAvatar = DDSystem.x(10)
    static var maxBubbleWidth: CGFloat = DDSystem.x(320) - 2 * avatarSize.width - 2 * margin - spacingBetweenBubbleAndAvatar

    var model: DDChatModel!
    var avatar: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(white: 235 / 255, alpha: 1)
        self.selectionStyle = .None
        
        avatar = UIImageView(frame: CGRect(origin: CGPointZero, size: DDChatCell.avatarSize))
        avatar.top = DDChatCell.margin
        self.contentView.addSubview(avatar)
    }
    
    func setupWithModel(model: DDChatModel) {
        self.model = model
        
        if model.isMe {
            avatar.image = UIImage(named:"DDChat.bundle/avatar_male")
            avatar.right = self.contentView.width - DDChatCell.margin
        }else {
            avatar.image = UIImage(named:"DDChat.bundle/avatar_female")
            avatar.left = DDChatCell.margin
        }
    }
}

class DDChatTextCell: DDChatCell {
    var name: String!
    var bubble: DDBubbleTextButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        bubble = DDBubbleTextButton()
        bubble.touchUpInsideHandler = { [weak self] button in
            DDLog2.print("bubble text clicked")
            if let vc = self?.viewController as? DDChatController {
                vc.textButtonClicked(button as? DDBubbleTextButton, model: self?.model as? DDChatTextModel)
            }
        }
        self.contentView.addSubview(bubble)
    }
    
    override func setupWithModel(model: DDChatModel) {
        super.setupWithModel(model)
        
        let textModel = model as! DDChatTextModel
        
        bubble.prepareForReuse()
        bubble.setBackgroundImage(textModel.bubbleBackgroundImage, forState: .Normal)
        bubble.setBackgroundImage(textModel.bubbleBackgroundHighlightedImage, forState: .Highlighted)
        bubble.contentInset = textModel.bubbleContentInsets
        bubble.richTextSections = textModel.richTextSections
//        self.bubble.size = CGSize(width: DDChatCell.maxBubbleWidth, height: textModel.bubbleHeight)
        bubble.width = DDChatCell.maxBubbleWidth
//        DDLog2.print("self.bubble 3\(self.bubble)")
        bubble.height = CGFloat.max
//        DDLog2.print("self.bubble 4\(self.bubble)")
        bubble.sizeToFit()
//        DDLog2.print("self.bubble \(self.bubble)")
        bubble.top = avatar.top
//        DDLog2.print("self.bubble.contentView \(self.bubble.contentView)")
        
        if textModel.isMe {
            bubble.right = avatar.left - DDChatCell.spacingBetweenBubbleAndAvatar
        }else {
            bubble.left = avatar.right + DDChatCell.spacingBetweenBubbleAndAvatar
        }
        
        if textModel.hasSectionSeparators {
            self.bubble.addSectionSeparators({ (rect, index) -> UIView! in
                if index > 0 && index < textModel.richTextSections.count - 1 {
                    let separatorWidth = self.bubble.width * 3 / 4
                    let separatorHeight: CGFloat = 1
                    let separator = UIView(frame: CGRect(x: 12, y: CGRectGetMaxY(rect) - separatorHeight, width: separatorWidth, height: separatorHeight))
                    separator.backgroundColor = UIColor.grayColor()
                    return separator
                }else {
                    return nil
                }
            })
        }
        
        if textModel.hasAdditionalImages {
            self.bubble.addSectionImages()
        }
    }
    
//    func longPress(gesture: UILongPressGestureRecognizer) {
//        DDLog2.print("longPress gesture \(gesture)")
//        if gesture.state == .Began {
//            DDLog2.print("longPress did begin")
//        }
//    }
}

class DDChatVoiceCell: DDChatCell {
    var bubble: DDBubbleVoiceButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bubble = DDBubbleVoiceButton()
        bubble.top = self.avatar.top
        bubble.touchUpInsideHandler = { [weak self] button in
            DDLog2.print("bubble voice clicked")
            if let vc = self?.viewController as? DDChatController {
                vc.voiceButtonClicked(button as? DDBubbleVoiceButton, model: self?.model as? DDChatVoiceModel)
            }
        }
        self.contentView.addSubview(bubble)
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
        //        self.addGestureRecognizer(longPress)
    }
    
    override func setupWithModel(model: DDChatModel) {
        super.setupWithModel(model)
        
        let voiceModel = model as! DDChatVoiceModel
        
        bubble.prepareForReuse()
        bubble.setBackgroundImage(voiceModel.bubbleBackgroundImage, forState: .Normal)
        bubble.setBackgroundImage(voiceModel.bubbleBackgroundHighlightedImage, forState: .Highlighted)
        bubble.contentInset = voiceModel.bubbleContentInsets

        bubble.duration = CGFloat(voiceModel.duration)
        bubble.contentView.image = voiceModel.voiceImage
        bubble.contentView.animationImages = voiceModel.voiceAnimationImages
        bubble.height = 30
        bubble.sizeToFit()
//        //        DDLog2.print("self.bubble \(self.bubble)")
//        //        DDLog2.print("self.bubble.contentView \(self.bubble.contentView)")
//        
        if voiceModel.isMe {
            bubble.right = avatar.left - DDChatCell.spacingBetweenBubbleAndAvatar
            bubble.contentView.contentMode = .Right
        }else {
            bubble.left = avatar.right + DDChatCell.spacingBetweenBubbleAndAvatar
            bubble.contentView.contentMode = .Left
        }
        
        let player = DDPlayer.sharedPlayer
        if let voiceFileURL = voiceModel.fileURL, let playingURL = player.itemURL where voiceFileURL == playingURL {
            if player.isPlaying {
                let imageView = bubble.contentView
                imageView.startAnimating()
            }
        }
    }
}

class DDChatImageCell: DDChatCell {
    var bubble: DDBubbleImageButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bubble = DDBubbleImageButton()
        bubble.top = avatar.top
        bubble.touchUpInsideHandler = { [weak self] button in
            DDLog2.print("bubble image clicked")
            if let vc = self?.viewController as? DDChatController {
                vc.imageButtonClicked(button as? DDBubbleImageButton, model: self?.model as? DDChatImageModel)
            }
        }
        self.contentView.addSubview(bubble)
    }
    
    override func setupWithModel(model: DDChatModel) {
        super.setupWithModel(model)
        
        let imageModel = model as! DDChatImageModel
        
        bubble.prepareForReuse()
        bubble.setBackgroundImage(imageModel.bubbleBackgroundImage, forState: .Normal)
        bubble.setBackgroundImage(imageModel.bubbleBackgroundHighlightedImage, forState: .Highlighted)
        bubble.setImage(imageModel.image, forState: .Normal)
        bubble.maskImage = imageModel.maskImage
        bubble.sizeToFit()
        let bubbleHeight = bubble.height
        let height = bubbleHeight > DDChatCell.avatarSize.height ? bubbleHeight : DDChatCell.avatarSize.height
        bubble.height = height
        bubble.clipsToBubble()
        
        if imageModel.isMe {
            bubble.right = avatar.left - DDChatCell.spacingBetweenBubbleAndAvatar
        }else {
            bubble.left = avatar.right + DDChatCell.spacingBetweenBubbleAndAvatar
        }
    }
}
