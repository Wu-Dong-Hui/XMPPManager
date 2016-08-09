//
//  DDChatModel.swift
//  Dong
//
//  Created by darkdong on 15/1/22.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

private func insetsForBubble(image: UIImage!) -> UIEdgeInsets {
    let width = image.size.width
    let height = image.size.height
    return UIEdgeInsets(top: height * 3 / 4, left: width / 2, bottom: height / 4, right: width / 2)
}

class DDChatModel {
    struct Static {
        static var rightBubbleNormalImage: UIImage! = {
            let image = UIImage(named: "DDChat.bundle/bubble_right_normal")!
            return image.resizableImage(insetsForBubble(image))
            }()
        static var rightBubbleHighlightedImage: UIImage! = {
            let image = UIImage(named: "DDChat.bundle/bubble_right_highlighted")!
            return image.resizableImage(insetsForBubble(image))
            }()
        static var leftBubbleNormalImage: UIImage! = {
            let image = UIImage(named: "DDChat.bundle/bubble_left_normal")!
            return image.resizableImage(insetsForBubble(image))
            }()
        static var leftBubbleHighlightedImage: UIImage! = {
            let image = UIImage(named: "DDChat.bundle/bubble_left_highlighted")!
            return image.resizableImage(insetsForBubble(image))
            }()
    }
    class var reusableCellIdentifier: String! {
        return nil
    }
    
    var bubbleBackgroundImage: UIImage!
    var bubbleBackgroundHighlightedImage: UIImage!
    var bubbleContentInsets = UIEdgeInsetsZero
    
    var isMe: Bool = false
    
    var bubbleHeight: CGFloat!
    var cellHeight: CGFloat!
    
    init(isMe: Bool) {
        self.isMe = isMe
    }
    
    func calculateHeight(force: Bool = false) {
        if self.cellHeight == nil || force {
            self.cellHeight = DDChatCell.avatarSize.height + 2 * DDChatCell.margin
        }
    }
}

class DDRichTextSectionImageInfo {
    var image: UIImage!
    var insets: DDEdgeInsets = .Nil
    var horizontalAlignment: UIControlContentHorizontalAlignment = .Center
    var verticalAlignment: UIControlContentVerticalAlignment = .Center
    
    init(image: UIImage!) {
        self.image = image
    }
}

class DDRichTextSection {
    var attributedString: NSAttributedString!
    var range: NSRange!
    var rect: CGRect!
    var imageInfos: [DDRichTextSectionImageInfo]!
    var handler: DDButtonEventHandler!
    
    init(attributedString: NSAttributedString!) {
        
        var attributes = [String: AnyObject]()
        
        let font: AnyObject? = attributedString.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil)
        if font == nil {
            attributes[NSFontAttributeName] = UIFont.systemFontOfSize(14)
        }
        
        if attributes.count > 0 {
            let astring = NSMutableAttributedString(attributedString: attributedString)
            let range = NSMakeRange(0, attributedString.length)
            astring.addAttributes(attributes, range: range)
            self.attributedString = astring.copy() as! NSAttributedString
        }else {
            self.attributedString = attributedString
        }        
    }
}

class DDChatTextModel: DDChatModel {
    override class var reusableCellIdentifier: String! {
        return NSStringFromClass(DDChatTextCell)
    }
    var richTextSections: [DDRichTextSection]!
    var attributedString: NSAttributedString! {
        let totalAttributedText = NSMutableAttributedString()
        for section in self.richTextSections {
            totalAttributedText.appendAttributedString(section.attributedString)
        }
        return totalAttributedText
    }
    var hasSectionSeparators = false
    var hasAdditionalImages = false
    
    class func createTextModel(sections sections: [DDRichTextSection]!, isMe: Bool) -> DDChatTextModel! {
        struct Static {
            static var rightTitledBubbleNormalImage: UIImage! = {
                let image = UIImage(named: "DDChat.bundle/bubble_title_right_normal")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var rightTitledBubbleHighlightedImage: UIImage! = {
                let image = UIImage(named: "DDChat.bundle/bubble_title_right_highlighted")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var leftTitledBubbleNormalImage: UIImage! = {
                let image = UIImage(named: "DDChat.bundle/bubble_title_left_normal")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var leftTitledBubbleHighlightedImage: UIImage! = {
                let image = UIImage(named: "DDChat.bundle/bubble_title_left_highlighted")!
                return image.resizableImage(insetsForBubble(image))
                }()
        }

        let chatTextModel = DDChatTextModel(sections: sections, isMe: isMe)
        let hasMultiSections = sections.count > 1
        
        var bubbleBackgroundImage: UIImage!
        var bubbleBackgroundHighlightedImage: UIImage!
        var bubbleContentInsets = UIEdgeInsetsZero
        
        if isMe {
            if hasMultiSections {
                bubbleBackgroundImage = Static.rightTitledBubbleNormalImage
                bubbleBackgroundHighlightedImage =  Static.rightTitledBubbleHighlightedImage
                bubbleContentInsets =  UIEdgeInsetsMake(10, 56, 10, 20)
            }else {
                bubbleBackgroundImage = DDChatModel.Static.rightBubbleNormalImage
                bubbleBackgroundHighlightedImage = DDChatModel.Static.rightBubbleHighlightedImage
                bubbleContentInsets = UIEdgeInsetsMake(6, 10, 14, 12)
            }
        }else {
            if hasMultiSections {
                bubbleBackgroundImage = Static.leftTitledBubbleNormalImage
                bubbleBackgroundHighlightedImage =  Static.leftTitledBubbleHighlightedImage
                bubbleContentInsets =  UIEdgeInsetsMake(10, 20, 10, 56)
            }else {
                bubbleBackgroundImage = DDChatModel.Static.leftBubbleNormalImage
                bubbleBackgroundHighlightedImage = DDChatModel.Static.leftBubbleHighlightedImage
                bubbleContentInsets = UIEdgeInsetsMake(6, 12, 14, 10)
            }
        }
        
        chatTextModel.bubbleBackgroundImage = bubbleBackgroundImage
        chatTextModel.bubbleBackgroundHighlightedImage = bubbleBackgroundHighlightedImage
        chatTextModel.bubbleContentInsets = bubbleContentInsets
        return chatTextModel
    }
    
    class func createTextModel(text text: String!, isMe: Bool) -> DDChatTextModel! {
        let section = DDRichTextSection(attributedString: NSAttributedString(string: text))
        return self.createTextModel(sections: [section], isMe: isMe)
    }
    
    private init(sections: [DDRichTextSection]!, isMe: Bool) {
        super.init(isMe: isMe)
        
        var position = 0
        for (_, section) in sections.enumerate() {
            let sectionLength = section.attributedString.length
            section.range = NSMakeRange(position, sectionLength)
            position += sectionLength
        }
        self.richTextSections = sections
    }
    
    override func calculateHeight(force: Bool = false) {
        if self.bubbleHeight == nil || force {
            let bubbleContentInset = self.bubbleContentInsets
            let constraintWidth = DDChatCell.maxBubbleWidth - bubbleContentInset.left - bubbleContentInset.right
            let boundingRect = self.attributedString.boundingRectWithSize(CGSize(width: constraintWidth, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
            let contentSize = CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
            let bubbleHeight = contentSize.height + bubbleContentInset.top + bubbleContentInset.bottom
            self.bubbleHeight = bubbleHeight > DDChatCell.avatarSize.height ? bubbleHeight : DDChatCell.avatarSize.height
        }
        if self.cellHeight == nil || force {
            self.cellHeight = self.bubbleHeight + 2 * DDChatCell.margin
        }
    }
}

class DDChatVoiceModel: DDChatModel {
    override class var reusableCellIdentifier: String! {
        return NSStringFromClass(DDChatVoiceCell)
    }
    
    var fileURL: NSURL!
    var duration: NSTimeInterval = 0
    
    var voiceImage: UIImage!
    var voiceAnimationImages: [UIImage]!
    
    class func createVoiceModel(fileURL fileURL: NSURL!, duration: NSTimeInterval, isMe: Bool) -> DDChatVoiceModel! {
        struct Static {
            static var rightVoiceImage: UIImage! = {
                return UIImage(namedNoCache: "DDChat.bundle/voice_right")
                }()
            static var rightVoiceAnimationImages: [UIImage]! = {
                return [
                    UIImage(namedNoCache: "DDChat.bundle/voice_right_frame1")!,
                    UIImage(namedNoCache: "DDChat.bundle/voice_right_frame2")!,
                    UIImage(namedNoCache: "DDChat.bundle/voice_right_frame3")!,
                ]
                }()
            static var leftVoiceImage: UIImage! = {
                return UIImage(namedNoCache: "DDChat.bundle/voice_left")
                }()
            static var leftVoiceAnimationImages: [UIImage]! = {
                return [
                    UIImage(namedNoCache: "DDChat.bundle/voice_left_frame1")!,
                    UIImage(namedNoCache: "DDChat.bundle/voice_left_frame2")!,
                    UIImage(namedNoCache: "DDChat.bundle/voice_left_frame3")!,
                ]
                }()
        }
        let chatVoiceModel = DDChatVoiceModel(fileURL: fileURL, duration: duration, isMe: isMe)
        
        var bubbleBackgroundImage: UIImage!
        var bubbleBackgroundHighlightedImage: UIImage!
        var bubbleContentInsets = UIEdgeInsetsZero
        var voiceImage: UIImage!
        var voiceAnimationImages: [UIImage]!
        
        if isMe {
            bubbleBackgroundImage = DDChatModel.Static.rightBubbleNormalImage
            bubbleBackgroundHighlightedImage = DDChatModel.Static.rightBubbleHighlightedImage
            bubbleContentInsets = UIEdgeInsetsMake(6, 10, 14, 12)
            voiceImage = Static.rightVoiceImage
            voiceAnimationImages = Static.rightVoiceAnimationImages
        }else {
            bubbleBackgroundImage = DDChatModel.Static.leftBubbleNormalImage
            bubbleBackgroundHighlightedImage = DDChatModel.Static.leftBubbleHighlightedImage
            bubbleContentInsets = UIEdgeInsetsMake(6, 12, 14, 10)
            voiceImage = Static.leftVoiceImage
            voiceAnimationImages = Static.leftVoiceAnimationImages
        }
        
        chatVoiceModel.bubbleBackgroundImage = bubbleBackgroundImage
        chatVoiceModel.bubbleBackgroundHighlightedImage = bubbleBackgroundHighlightedImage
        chatVoiceModel.bubbleContentInsets = bubbleContentInsets
        chatVoiceModel.voiceImage = voiceImage
        chatVoiceModel.voiceAnimationImages = voiceAnimationImages
        return chatVoiceModel
    }
    
    private init(fileURL: NSURL!, duration: NSTimeInterval, isMe: Bool) {
        super.init(isMe: isMe)
        
        self.fileURL = fileURL
        self.duration = duration
    }
}

class DDChatImageModel: DDChatModel {
    override class var reusableCellIdentifier: String! {
        return NSStringFromClass(DDChatImageCell)
    }
    
    var image: UIImage!
    var maskImage: UIImage!

    class func createImageModel(image image: UIImage!, isMe: Bool) -> DDChatImageModel! {
        struct Static {
            static var rightNormalImage: UIImage! = {
                let image = UIImage(namedNoCache: "DDChat.bundle/bubble_image_right_normal")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var rightHighlightedImage: UIImage! = {
                let image =  UIImage(namedNoCache: "DDChat.bundle/bubble_image_right_highlighted")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var rightMaskImage: UIImage! = {
                let image =  UIImage(namedNoCache: "DDChat.bundle/bubble_image_right_mask")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var leftNormalImage: UIImage! = {
                let image =  UIImage(namedNoCache: "DDChat.bundle/bubble_image_left_normal")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var leftHighlightedImage: UIImage! = {
                let image =  UIImage(namedNoCache: "DDChat.bundle/bubble_image_left_highlighted")!
                return image.resizableImage(insetsForBubble(image))
                }()
            static var leftMaskImage: UIImage! = {
                let image =  UIImage(namedNoCache: "DDChat.bundle/bubble_image_left_mask")!
                return image.resizableImage(insetsForBubble(image))
                }()
        }
        let chatImageModel = DDChatImageModel(image: image, isMe: isMe)
        
        var bubbleBackgroundImage: UIImage!
        var bubbleBackgroundHighlightedImage: UIImage!
        var maskImage: UIImage!
        
        if isMe {
            bubbleBackgroundImage = Static.rightNormalImage
            bubbleBackgroundHighlightedImage = Static.rightHighlightedImage
            maskImage = Static.rightMaskImage
        }else {
            bubbleBackgroundImage = Static.leftNormalImage
            bubbleBackgroundHighlightedImage = Static.leftHighlightedImage
            maskImage = Static.leftMaskImage
        }
        
        chatImageModel.bubbleBackgroundImage = bubbleBackgroundImage
        chatImageModel.bubbleBackgroundHighlightedImage = bubbleBackgroundHighlightedImage
        chatImageModel.image = image
        chatImageModel.maskImage = maskImage
        return chatImageModel
    }
    
    private init(image: UIImage!, isMe: Bool) {
        super.init(isMe: isMe)
        
        self.image = image
    }
    
    override func calculateHeight(force: Bool = false) {
        if self.bubbleHeight == nil || force {
            let bubbleHeight: CGFloat
            if let size = self.image?.size.scaleToFillSize(DDBubbleImageButton.constraintSize) {
                bubbleHeight = size.height
            }else {
                bubbleHeight = DDBubbleImageButton.constraintSize.height
            }
            self.bubbleHeight = bubbleHeight > DDChatCell.avatarSize.height ? bubbleHeight : DDChatCell.avatarSize.height
        }
        if self.cellHeight == nil || force {
            self.cellHeight = self.bubbleHeight + 2 * DDChatCell.margin
        }
    }
}
