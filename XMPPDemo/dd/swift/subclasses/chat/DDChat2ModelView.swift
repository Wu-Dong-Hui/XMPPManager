//
//  DDChat2ModelView.swift
//  Dong
//
//  Created by darkdong on 15/10/28.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

//MARK: - DDChatModel

class DDChatUser: NSObject {
    static var rightImage: UIImage? = {
        return UIImage(namedNoCache:"DDChat.bundle/avatar_male")
    }()
    
    static var leftImage: UIImage? = {
        return UIImage(namedNoCache:"DDChat.bundle/avatar_female")
    }()
    
    override var description: String {
        return "DDChatUser: \(self.desc())"
    }
    
    enum Identity {
        case Me
        case Other
    }
    var identity = Identity.Me
    var image: UIImage?
    var imageURL: NSURL?
    var placeholderImage: UIImage?
    
    init(identity: Identity) {
        super.init()
        
        self.identity = identity
    }
    
    func isMe() -> Bool {
        return identity == .Me
    }
    
    func desc() -> String {
        switch identity {
        case .Me:
            return "Me"
        case .Other:
            return "Other"
        }
    }
}

//MARK: - DDChatStyle

class DDChatStyle: NSObject {
    
}

class DDChatBubbleStyle: DDChatStyle {
    static var bubbleLeftNormalImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_left_normal")?.resizableImage()
    }()
    
    static var bubbleLeftHighlightedImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_left_highlighted")?.resizableImage()
    }()
    
    static var bubbleLeftInsets: UIEdgeInsets = {
        return UIEdgeInsetsMake(10, 18, 18, 16)
    }()
    
    static var bubbleRightNormalImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_right_normal")?.resizableImage()
    }()
    
    static var bubbleRightHighlightedImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_right_highlighted")?.resizableImage()
    }()
    
    static var bubbleRightInsets: UIEdgeInsets = {
        return UIEdgeInsetsMake(10, 18, 18, 16)
    }()
    
    var bubbleImage: UIImage?
    var bubbleHighlightedImage: UIImage?
    var bubbleInsets = UIEdgeInsetsZero
    
    override init() {
        super.init()
    }
    
    init(isMe: Bool) {
        let bubbleImage: UIImage?
        let bubbleHighlightedImage: UIImage?
        let bubbleInsets: UIEdgeInsets

        if isMe {
            bubbleImage = DDChatBubbleStyle.bubbleRightNormalImage
            bubbleHighlightedImage = DDChatBubbleStyle.bubbleRightHighlightedImage
            bubbleInsets = DDChatBubbleStyle.bubbleRightInsets
        }else {
            bubbleImage = DDChatBubbleStyle.bubbleLeftNormalImage
            bubbleHighlightedImage = DDChatBubbleStyle.bubbleLeftHighlightedImage
            bubbleInsets = DDChatBubbleStyle.bubbleLeftInsets
        }
        
        self.bubbleImage = bubbleImage
        self.bubbleHighlightedImage = bubbleHighlightedImage
        self.bubbleInsets = bubbleInsets
    }
    
    init(bubbleImage: UIImage?, bubbleHighlightedImage: UIImage?, bubbleInsets: UIEdgeInsets) {
        super.init()
        
        self.bubbleImage = bubbleImage
        self.bubbleHighlightedImage = bubbleHighlightedImage
        self.bubbleInsets = bubbleInsets
    }
}

class DDChatTextBubbleStyle: DDChatBubbleStyle {
    static var textAttributes: [String : AnyObject] = {
        let attributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        return attributes
    }()
    
    var textAttributes: [String : AnyObject]?
    
    override init(isMe: Bool) {
        super.init(isMe: isMe)
        
        self.textAttributes = DDChatTextBubbleStyle.textAttributes
    }
    
    init(bubbleImage: UIImage?, bubbleHighlightedImage: UIImage?, bubbleInsets: UIEdgeInsets, textAttributes: [String : AnyObject]?) {
        super.init(bubbleImage: bubbleImage, bubbleHighlightedImage: bubbleHighlightedImage, bubbleInsets: bubbleInsets)
        
        self.textAttributes = textAttributes
    }
}

class DDChatImageBubbleStyle: DDChatStyle {
    static var bubbleLeftMaskImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_image_left_mask")?.resizableImage()
    }()
    
    static var bubbleRightMaskImage: UIImage! = {
        return UIImage(namedNoCache:"DDChat.bundle/bubble_image_right_mask")?.resizableImage()
    }()

    var bubbleMaskImage: UIImage?
    
    init(isMe: Bool) {
        let bubbleMaskImage: UIImage?
        
        if isMe {
            bubbleMaskImage = DDChatImageBubbleStyle.bubbleRightMaskImage
        }else {
            bubbleMaskImage = DDChatImageBubbleStyle.bubbleLeftMaskImage
        }
        
        self.bubbleMaskImage = bubbleMaskImage
    }
    
    init(bubbleMaskImage: UIImage?) {
        super.init()
        
        self.bubbleMaskImage = bubbleMaskImage
    }
}

class DDChatVoiceBubbleStyle: DDChatBubbleStyle {
    static var voiceLeftImage: UIImage! = {
        return UIImage(namedNoCache: "DDChat.bundle/voice_left")
    }()
    
    static var voiceLeftAnimationImages: [UIImage]! = {
        return [
            UIImage(namedNoCache: "DDChat.bundle/voice_left_frame1")!,
            UIImage(namedNoCache: "DDChat.bundle/voice_left_frame2")!,
            UIImage(namedNoCache: "DDChat.bundle/voice_left_frame3")!,
        ]
    }()
    
    static var voiceRightImage: UIImage! = {
        return UIImage(namedNoCache: "DDChat.bundle/voice_right")
    }()
    
    static var voiceRightAnimationImages: [UIImage]! = {
        return [
            UIImage(namedNoCache: "DDChat.bundle/voice_right_frame1")!,
            UIImage(namedNoCache: "DDChat.bundle/voice_right_frame2")!,
            UIImage(namedNoCache: "DDChat.bundle/voice_right_frame3")!,
        ]
    }()
    
    var voiceImage: UIImage?
    var voiceAnimationImages: [UIImage]?
    
    override init(isMe: Bool) {
        super.init(isMe: isMe)
        
        let voiceImage: UIImage?
        let voiceAnimationImages: [UIImage]?
        
        if isMe {
            voiceImage = DDChatVoiceBubbleStyle.voiceRightImage
            voiceAnimationImages = DDChatVoiceBubbleStyle.voiceRightAnimationImages
        }else {
            voiceImage = DDChatVoiceBubbleStyle.voiceLeftImage
            voiceAnimationImages = DDChatVoiceBubbleStyle.voiceLeftAnimationImages
        }
        self.voiceImage = voiceImage
        self.voiceAnimationImages = voiceAnimationImages
    }
        
    init(bubbleImage: UIImage?, bubbleHighlightedImage: UIImage?, bubbleInsets: UIEdgeInsets, voiceImage: UIImage?, voiceAnimationImages: [UIImage]?) {
        super.init(bubbleImage: bubbleImage, bubbleHighlightedImage: bubbleHighlightedImage, bubbleInsets: bubbleInsets)

        self.voiceImage = voiceImage
        self.voiceAnimationImages = voiceAnimationImages
    }
}

//MARK: - DDChatModel

class DDChat2Model: NSObject, DDCellModel, DDCellGeometryFlexible {
    class var cellClass: AnyClass {
        return DDChat2Cell.self
    }
    class var cellReuseIdentifier: String {
        return NSStringFromClass(cellClass)
    }
    
    var user: DDChatUser
    var cellSize: CGSize?
    
    init(user: DDChatUser) {
        self.user = user
        super.init()
    }
    
    func calculateGeometry(forced: Bool) {}
}

class DDChat2TextModel: DDChat2Model {
    override class var cellClass: AnyClass {
        return DDChat2TextCell.self
    }
    override class var cellReuseIdentifier: String {
        return NSStringFromClass(cellClass)
    }
    
    override var description: String {
        return "DDChat2TextModel: \(user) attributedText \(attributedText)"
    }
    
    var attributedText: NSAttributedString
    var style: DDChatBubbleStyle
    var bubbleSize: CGSize?

    init(attributedText: NSAttributedString, user: DDChatUser, style: DDChatBubbleStyle? = nil) {
        self.attributedText = attributedText
        self.style = style ?? DDChatBubbleStyle(isMe: user.isMe())
        super.init(user: user)
    }
    
    override func calculateGeometry(forced: Bool) {
        if bubbleSize == nil || forced {
            let insets = style.bubbleInsets
            //            DDLog2.print("attributedText MUST BE EQUAL \(attributedText)")
            let constraintWidth = DDChat2AvatarBubbleCell.maxBubbleWidth - insets.left - insets.right
            let boundingRect = attributedText.boundingRectWithSize(CGSize(width: constraintWidth, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
            let contentSize = CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
            let w = contentSize.width + insets.left + insets.right
            var h = contentSize.height + insets.top + insets.bottom
            if h < DDChat2AvatarBubbleCell.avatarDimension {
                h = DDChat2AvatarBubbleCell.avatarDimension
            }
            bubbleSize = CGSize(width: w, height: h)
        }
        if cellSize == nil || forced {
            let cellWidth = DDSystem.x(320)
            let cellHeight = bubbleSize!.height + 2 * DDChat2AvatarBubbleCell.margin
            cellSize = CGSize(width: cellWidth, height: cellHeight).ceilIntSize
//            DDLog2.print("DDChat2TextModel cellSize \(cellSize)")
        }
    }
}

class DDChat2ImageModel: DDChat2Model {
    override class var cellClass: AnyClass {
        return DDChat2ImageCell.self
    }
    override class var cellReuseIdentifier: String {
        return NSStringFromClass(cellClass)
    }
    
    override var description: String {
        return "DDChat2ImageModel: \(user) image.size \(image.size)"
    }

    var image: UIImage
    var style: DDChatImageBubbleStyle
    var bubbleSize: CGSize?
    var bubbleContentMode: UIViewContentMode?
    
    init(image: UIImage, user: DDChatUser, style: DDChatImageBubbleStyle? = nil) {
        self.image = image
        self.style = style ?? DDChatImageBubbleStyle(isMe: user.isMe())
        super.init(user: user)
    }
    
    override func calculateGeometry(forced: Bool) {
        if bubbleSize == nil || forced {
            let imageSize = image.size
            let maxBubbleSize = DDChat2ImageCell.maxBubbleSize
            let minBubbleSize = DDChat2ImageCell.minBubbleSize

//            DDLog2.print("DDChat2ImageModel imageSize \(imageSize)")
//            DDLog2.print("DDChat2ImageModel minBubbleSize \(minBubbleSize)")

            if imageSize.width > maxBubbleSize.width || imageSize.height > maxBubbleSize.height {
                bubbleSize = imageSize.scaleToFitSize(maxBubbleSize)
                bubbleContentMode = UIViewContentMode.ScaleAspectFit
            }else {
                bubbleSize = imageSize.scaleToFillSize(minBubbleSize)
                bubbleContentMode = UIViewContentMode.ScaleAspectFill
            }
//            DDLog2.print("DDChat2ImageModel bubbleSize \(bubbleSize)")
        }
        if cellSize == nil || forced {
            let cellWidth = DDSystem.x(320)
            let cellHeight = bubbleSize!.height + 2 * DDChat2AvatarBubbleCell.margin
            cellSize = CGSize(width: cellWidth, height: cellHeight).ceilIntSize
//            DDLog2.print("DDChat2ImageModel cellSize \(cellSize)")
        }
    }
}

class DDChat2VoiceModel: DDChat2Model {
    override class var cellClass: AnyClass {
        return DDChat2VoiceCell.self
    }
    override class var cellReuseIdentifier: String {
        return NSStringFromClass(cellClass)
    }
    
    override var description: String {
        return "DDChat2VoiceModel: \(user) duration \(duration) isPlaying \(isPlaying)"
    }

    static var minDuration: NSTimeInterval = 1
    static var maxDuration: NSTimeInterval = 10

    var fileURL: NSURL
    var duration: NSTimeInterval
    var style: DDChatVoiceBubbleStyle
    var bubbleSize: CGSize?
    var isPlaying: Bool = false

    init(fileURL: NSURL, duration: NSTimeInterval, user: DDChatUser, style: DDChatVoiceBubbleStyle? = nil) {
        self.fileURL = fileURL
        if duration < DDChat2VoiceModel.minDuration {
            self.duration = DDChat2VoiceModel.minDuration
        }else if duration > DDChat2VoiceModel.maxDuration {
            self.duration = DDChat2VoiceModel.maxDuration
        }else {
            self.duration = duration
        }
        self.style = style ?? DDChatVoiceBubbleStyle(isMe: user.isMe())

        super.init(user: user)
    }
    
    override func calculateGeometry(forced: Bool) {
        if bubbleSize == nil || forced {
            let x1 = CGFloat(DDChat2VoiceModel.minDuration)
            let x2 = CGFloat(DDChat2VoiceModel.maxDuration)
            let x = CGFloat(duration)
            let y1 = DDChat2VoiceCell.minVoiceBubbleWidth
            let y2 = DDChat2VoiceCell.maxVoiceBubbleWidth

            let bubbleWidth = DDMath.similarY(x1: x1, x: x, x2: x2, y1: y1, y2: y2)
            bubbleSize = CGSize(width: bubbleWidth, height: DDChat2AvatarBubbleCell.avatarDimension)
        }
        if cellSize == nil || forced {
            let cellWidth = DDSystem.x(320)
            let cellHeight = DDChat2AvatarBubbleCell.avatarDimension + 2 * DDChat2AvatarBubbleCell.margin
            cellSize = CGSize(width: cellWidth, height: cellHeight).ceilIntSize
//            DDLog2.print("DDChat2VoiceModel cellSize \(cellSize)")
        }
    }
}

//MARK: - DDChatCell

class DDChat2Cell: UICollectionViewCell, DDCellReusable {
    var model: DDChat2Model!
    
    func reuseWithModel(model: AnyObject) {
        self.model = model as? DDChat2Model
    }
}

class DDChat2AvatarBubbleCell: DDChat2Cell {
    static var margin = DDSystem.x(10)
    static var avatarDimension = DDSystem.x(44)
    static var spacingBetweenAvatarAndBubble = DDSystem.x(4)
    static var maxBubbleWidth: CGFloat = DDSystem.x(320) - 2 * avatarDimension - 2 * margin - 2 * spacingBetweenAvatarAndBubble
    
    var avatar: UIImageView?
    var bubble: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let avatarDimension = self.dynamicType.avatarDimension
        let avatarSize = CGSize(width: avatarDimension, height: avatarDimension)
        avatar = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: self.dynamicType.margin), size: avatarSize))
        avatar?.clipsToBounds = true
        avatar?.contentMode = .ScaleAspectFill
        contentView.addSubview(avatar!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reuseWithModel(model: AnyObject) {
        super.reuseWithModel(model)
        
        guard let avatar = avatar else {
            return
        }
        
        avatar.image = model.user.placeholderImage
        
        if let image = model.user.image {
            avatar.image = image
        }else if let imageURL = model.user.imageURL {
//            avatar.setImageWithURL(imageURL)
        }
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let avatar = avatar else {
            return
        }
        
        let margin = self.dynamicType.margin
        let spacing = self.dynamicType.spacingBetweenAvatarAndBubble
        
        if model.user.isMe() {
            avatar.right = contentView.width - margin
            bubble?.right = avatar.left - spacing
        }else {
            avatar.left = margin
            bubble?.left = avatar.right + spacing
        }
        bubble?.top = avatar.top
    }
}

class DDChat2TextCell: DDChat2AvatarBubbleCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textButton = DDChatTextButton()
        textButton.touchUpInsideHandler = { [weak self] btn in
            if let vc = self?.viewController as? DDChat2Controller, model = self?.model as? DDChat2TextModel {
                vc.textButtonClicked(btn as! DDChatTextButton, model: model)
            }
        }
        contentView.addSubview(textButton)
        bubble = textButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reuseWithModel(model: AnyObject) {
        super.reuseWithModel(model)
        
        let textModel = model as! DDChat2TextModel
        let styleModel = textModel.style
        let textBubble = bubble as! DDChatTextButton
        
        textBubble.setBackgroundImage(styleModel.bubbleImage, forState: .Normal)
        textBubble.setBackgroundImage(styleModel.bubbleHighlightedImage, forState: .Highlighted)
        textBubble.size = textModel.bubbleSize!
        textBubble.textViewInsets = styleModel.bubbleInsets
        textBubble.attributedText = textModel.attributedText
    }
}

class DDChat2ImageCell: DDChat2AvatarBubbleCell {
    static var maxBubbleSize = CGSize(width: maxBubbleWidth, height: maxBubbleWidth)
    static var minBubbleSize = CGSize(width: avatarDimension, height: avatarDimension)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let imageButton = DDChatImageButton()
        imageButton.touchUpInsideHandler = { [weak self] btn in
            if let vc = self?.viewController as? DDChat2Controller, model = self?.model as? DDChat2ImageModel where !vc.inputBar.inputVoiceView.recording {
                vc.imageButtonClicked(btn as! DDChatImageButton, model: model)
            }
        }
        contentView.addSubview(imageButton)
        bubble = imageButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let imageBubble = bubble as! DDChatImageButton
        imageBubble.prepareForReuse()
    }
    
    override func reuseWithModel(model: AnyObject) {
        super.reuseWithModel(model)
        
        let imageModel = model as! DDChat2ImageModel
        let imageBubble = bubble as! DDChatImageButton

        imageBubble.size = imageModel.bubbleSize!
        imageBubble.setImage(imageModel.image, style: imageModel.style, contentMode: imageModel.bubbleContentMode!)
    }
}

class DDChat2VoiceCell: DDChat2AvatarBubbleCell {
    static var minVoiceBubbleWidth = avatarDimension
    static var maxVoiceBubbleWidth = maxBubbleWidth

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let voiceButton = DDChatVoiceButton()
        voiceButton.touchUpInsideHandler = { [weak self] btn in
            if let vc = self?.viewController as? DDChat2Controller, model = self?.model as? DDChat2VoiceModel {
                vc.voiceButtonClicked(btn as! DDChatVoiceButton, model: model)
            }
        }
        contentView.addSubview(voiceButton)
        bubble = voiceButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reuseWithModel(model: AnyObject) {
        super.reuseWithModel(model)
        
        let voiceModel = model as! DDChat2VoiceModel
        let voiceBubble = bubble as! DDChatVoiceButton

        voiceBubble.size = voiceModel.bubbleSize!
        voiceBubble.setVoice(voiceModel.isPlaying, style: voiceModel.style, isMe: voiceModel.user.isMe())
    }
}
