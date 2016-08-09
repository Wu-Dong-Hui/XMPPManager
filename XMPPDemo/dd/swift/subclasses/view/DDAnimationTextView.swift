//
//  DDAnimationAttachment.swift
//  Dong
//
//  Created by darkdong on 15/1/15.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDAnimationAttachment: NSTextAttachment {
    var images: [UIImage]!
    var currentImageIndex: Int?
    
    func advance() {
        DDLog2.print("DDAnimationAttachment advance \(self)")
        if var index = self.currentImageIndex {
            index += 1
            if index < 0 || index >= self.images.count {
                index = 0
            }
            self.currentImageIndex = index
        }
    }
    
    override func imageForBounds(imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let index = self.currentImageIndex {
            DDLog2.print("return image at index \(index) imageBounds \(imageBounds) charIndex \(charIndex)")
            return self.images[index]
        }
        return nil
    }
}

class DDAnimationTextView: UITextView {
    var timer: DDTimer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
//        DDLog2.print("DDAnimationTextView init")
        self.timer = DDTimer(scheduleWithTimeInterval: 3, info: nil, repeats: true, handler: { [weak self] (_) -> Void in
            if let allAttributedString = self?.attributedText {
                allAttributedString.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, allAttributedString.length), options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (value, range, stop) -> Void in
                    if let animationAttachment = value as? DDAnimationAttachment {
                        DDLog2.print("DDAnimationTextView animate images \(self)")
                        animationAttachment.advance()
//                        DDLog2.print("invalidate range \(range)")
                        self?.layoutManager.invalidateDisplayForCharacterRange(range)
                    }
                })
            }
        })
    }
    
    deinit {
        DDLog2.print("DDAnimationTextView deinit")
        self.timer?.invalidate()
    }
}
