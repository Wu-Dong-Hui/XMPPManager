//
//  DDChatBubbleView.swift
//  Dong
//
//  Created by darkdong on 15/1/22.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDBubbleTextButton: DDButton, UITextViewDelegate {
    typealias SeparatorViewInRectHandler = (rect: CGRect!, index: Int) -> UIView!
    
    override var frame: CGRect {
        didSet {
            contentView?.frame = frame.rectByEdgeInsets(contentInset)
        }
    }
    var contentInset: UIEdgeInsets = UIEdgeInsetsZero
    var contentView: UITextView!
    var backgroundView: UIView?
    var richTextSections: [DDRichTextSection]! {
        willSet {
            if let sections = newValue {
                let totalAttributedText = NSMutableAttributedString()
                for section in sections {
                    totalAttributedText.appendAttributedString(section.attributedString)
                }
                self.contentView.attributedText = totalAttributedText
            }else {
                self.contentView.attributedText = nil
            }
        }
    }
    
    private func commonInit() {
        let contentView = UITextView()
        self.contentView = contentView
        //to use custom context menu
        contentView.userInteractionEnabled = false
        contentView.backgroundColor = UIColor.clearColor()
        contentView.bounces = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        contentView.textContainerInset = UIEdgeInsetsZero
        contentView.textContainer.lineFragmentPadding = 0
        contentView.delegate = self
        self.addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let constraintWidth = size.width - self.contentInset.left - self.contentInset.right
        let contentOrigin = CGPoint(x: self.contentInset.left, y: self.contentInset.top)
        let boundingRect = self.contentView.attributedText.boundingRectWithSize(CGSize(width: constraintWidth, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
        let contentSize = CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
        self.contentView.frame = CGRect(origin: contentOrigin, size: contentSize)
        
        DDLog2.print("DDBubbleTextButton sizeThatFits: constraintWidth \(constraintWidth) boundingRect \(boundingRect) contentView \(self.contentView)")
        DDLog2.print("self.contentView.attributedText \(self.contentView.attributedText)")

        return CGSize(width: self.contentInset.left + contentSize.width + self.contentInset.right, height: self.contentInset.top + contentSize.height + self.contentInset.bottom)
    }
    
    //MARK: - private
    
    func ensureSectionRectAndBackgroundView() -> UIView! {
        var backgroundView: UIView
        if self.backgroundView == nil {
            backgroundView = UIView(frame: self.bounds)
            self.backgroundView = backgroundView
            backgroundView.userInteractionEnabled = false
            //            self.clipsToBubble()
            self.calculateSectionRect()
        }else {
            backgroundView = self.backgroundView!
        }
        return backgroundView
    }
    
    private func calculateSectionRect() {
        if let sections = self.richTextSections {
            let layoutManager = self.contentView.layoutManager
            let textContainer = self.contentView.textContainer
            
            layoutManager.ensureLayoutForTextContainer(textContainer)
            
            for (index, section) in sections.enumerate() {
                let range = section.range
//                DDLog2.print("section range \(range)")
                if section.rect == nil {
                    var rect = layoutManager.boundingRectForGlyphRange(range, inTextContainer: textContainer)
//                    DDLog2.print("section rect\(rect)")
                    rect = CGRectOffset(rect, self.contentInset.left, self.contentInset.top)
                    rect.origin.x = 0
                    rect.size.width = self.width
                    
                    if index == 0 {
                        //the first
                        //                        DDLog2.print("first")
                        rect.size.height += rect.origin.y
                        rect.origin.y = 0
                    }
                    if index == self.richTextSections.count - 1 {
                        //the last, may be first too
                        //                        DDLog2.print("last")
                        rect.size.height += self.height - CGRectGetMaxY(rect)
                    }
//                    DDLog2.print("section rect final \(rect)")

                    section.rect = rect
                }
            }
        }
    }
    
    private func refreshBackgroundView() {
        if let backgroundView = self.backgroundView {
            self.insertSubview(backgroundView, aboveSubview: self.imageView!)
        }
    }
    
//    private func clipsToBubble() {
//        let maskView = UIImageView(frame: self.bounds)
//        maskView.image = self.backgroundImageForState(.Normal)
//        self.layer.mask = maskView.layer
//    }
    
    //MARK: - public
    func prepareForReuse() {
//        self.layer.mask = nil
        self.backgroundView?.removeFromSuperview()
        self.backgroundView = nil
    }
    
    func addSectionButtons() {
//        DDLog2.print("addSectionButtons")
        
        let backgroundView = self.ensureSectionRectAndBackgroundView()
        
        for attributedTextSection in self.richTextSections {
            let sectionButton = DDButton(frame: attributedTextSection.rect)
            sectionButton.touchUpInsideHandler = attributedTextSection.handler
            backgroundView.addSubview(sectionButton)
        }
        self.refreshBackgroundView()
    }
    
    func addSectionSeparators(separatorViewInRect: SeparatorViewInRectHandler) {
//        DDLog2.print("addSectionSeparators")
        
        let backgroundView = self.ensureSectionRectAndBackgroundView()
        
        for (index, section) in self.richTextSections.enumerate() {
            if let separator = separatorViewInRect(rect: section.rect, index: index) {
                backgroundView.addSubview(separator)
            }
        }
        self.refreshBackgroundView()
    }
    
    func addSectionImages() {
//        DDLog2.print("addSectionImages")
        
        let backgroundView = self.ensureSectionRectAndBackgroundView()
        
        for section in self.richTextSections {
            if let imageInfos = section.imageInfos {
                for imageInfo in imageInfos {
                    let imageView = UIImageView(image: imageInfo.image)
                    backgroundView.addSubview(imageView)
                    backgroundView.layoutView(imageView, constraintRect: section.rect, insets: imageInfo.insets, horizontalAlignment: imageInfo.horizontalAlignment, verticalAlignment: imageInfo.verticalAlignment)
                }
            }
        }
        self.refreshBackgroundView()
    }
    
    //MARK: - UITextViewDelegate
    
    //    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    //        DDLog2.print("shouldInteractWithURL \(URL)")
    //        return true
    //    }
    
    //MARK: - gesture handler
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        DDLog2.print("handleLongPress gesture \(gesture)")
        if gesture.state == .Began {
            DDLog2.print("longPress did begin")
            
            let targetView = gesture.view!
            targetView.becomeFirstResponder()
            
            let menuController = UIMenuController.sharedMenuController()
            menuController.setTargetRect(targetView.frame, inView: targetView.superview!)
            menuController.setMenuVisible(true, animated: true)
            
            let item1 = UIMenuItem(title: "lala", action: #selector(DDBubbleTextButton.lala(_:)))
            
            let item2 = UIMenuItem(title: "kaka", action: #selector(DDBubbleTextButton.kaka(_:)))
            menuController.menuItems = [item1, item2]
            menuController.update()
        }
    }
    
    //MARK: - override UIResponder for context menu
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(DDBubbleTextButton.copy(_:)) || action == #selector(DDBubbleTextButton.lala(_:)) || action == #selector(DDBubbleTextButton.kaka(_:))
    }
    
    //MARK: - UIResponderStandardEditActions
    override func copy(sender: AnyObject?) {
        DDLog2.print("menu item copy clicked")
    }
    
    //MARK: - custom context menu actions
    func lala(sender: AnyObject?) {
        DDLog2.print("menu item lala clicked")
    }
    
    func kaka(sender: AnyObject?) {
        DDLog2.print("menu item kaka clicked")
    }
}