//
//  DDInputTextView.swift
//  Dong
//
//  Created by darkdong on 15/9/3.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDInputTextView: UIView, UITextViewDelegate {
    static var log: DDLog2 = {
        let log = DDLog2()
        log.enabled = false
        return log
        }()

    static let suggestedBarHeight: CGFloat = 44
    
    var shouldChangeHeightAutomatically = false
    var maxNumberOfLines: Int? = 3
    var maxNumberOfCharacters: Int?
    
    var shouldResignFirstResponder = true {
        didSet {
            textView.shouldResignFirstResponder = shouldResignFirstResponder
        }
    }
    
    var didDeltaHeightHandler: ((CGFloat) -> Void)?
    var didChangeHandler: ((DDInputTextView) -> Void)?
    var didFinishHandler: ((DDInputTextView) -> Void)?
    var didOverflowHandler: ((Int) -> Void)?

    let textView: DDTextView
    var backgroundView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let backgroundView = backgroundView {
                backgroundView.frame = CGRect(origin: CGPointZero, size: frame.size)
                backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                insertSubview(backgroundView, atIndex: 0)
            }
        }
    }
    var placeholderView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            if let placeholderView = placeholderView {
                addSubview(placeholderView)
            }
            drawPlaceholderView()
        }
    }
    
    override var frame: CGRect {
        didSet {
            textView.frame = frame.rectByEdgeInsets(textViewInsets)
        }
    }
    
    var textViewInsets = UIEdgeInsetsZero {
        didSet {
            textView.frame = frame.rectByEdgeInsets(textViewInsets)
        }
    }
    
    var text: String! {
        get {
            return textView.text
        }
        set {
            if newValue == nil {
                textView.attributedText = nil
            }else {
                textView.attributedText = NSAttributedString(string: newValue, attributes: textView.typingAttributes)
            }
        }
    }
    
    var font: UIFont! {
        get {
            //At least, default typingAttributes has a font attribute
            return textView.typingAttributes[NSFontAttributeName] as? UIFont ?? textView.font
        }
        set {
            textView.typingAttributes[NSFontAttributeName] = newValue
        }
    }
    
    var textColor: UIColor! {
        get {
            return textView.typingAttributes[NSForegroundColorAttributeName] as? UIColor ?? textView.textColor
        }
        set {
            textView.typingAttributes[NSForegroundColorAttributeName] = newValue
        }
    }
    
    var lineSpacing: CGFloat {
        if let paragraphStyle = textView.typingAttributes[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            return paragraphStyle.lineSpacing
        }else {
            return 0
        }
    }
    
    var lineHeight: CGFloat {
        return font.lineHeight
    }
    var minTextViewHeight: CGFloat = 22
    var maxTextViewHeight: CGFloat {
        if let maxNumberOfLines = maxNumberOfLines {
            return CGFloat(maxNumberOfLines) * lineHeight + (CGFloat(maxNumberOfLines) - 1) * lineSpacing
        }else {
            return CGFloat.max
        }
    }
    
    override init(frame: CGRect) {
        DDInputTextView.log.print("DDInputTextView init \(frame)")

        textView = DDTextView(frame: frame.rectByEdgeInsets(textViewInsets))
        super.init(frame: frame)
        
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
        addSubview(textView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        DDInputTextView.log.print("DDInputTextView deinit")
    }

    //MARK: - override UIResponder
    
    override func isFirstResponder() -> Bool {
        return textView.isFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool {
        DDInputTextView.log.print("DDInputTextView becomeFirstResponder")
        return textView.becomeFirstResponder()
    }
    
    override func canResignFirstResponder() -> Bool {
        DDInputTextView.log.print("DDInputTextView canResignFirstResponder")
        return shouldResignFirstResponder
    }
    
    override func resignFirstResponder() -> Bool {
        DDInputTextView.log.print("DDInputTextView resignFirstResponder")
        return textView.resignFirstResponder()
    }

    //MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        DDInputTextView.log.print("DDInputTextView textViewDidChange \(textView.text)")

        adjustTextView(textView)
        drawPlaceholderView()
        
        if let handler = didChangeHandler {
            handler(self)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        DDInputTextView.log.print("DDInputTextView shouldChangeTextInRange range: \(range) replacementText: \(text) count: \(text.characters.count)")
        if text == "\n" {
            didFinishHandler?(self)
            return false
        }
        if let maxNumberOfCharacters = maxNumberOfCharacters {
            //should limit number of characters
            var currentText = self.text ?? ""
            let start = currentText.startIndex.advancedBy(range.location)
            let end = currentText.startIndex.advancedBy(range.location + range.length)
            let currentRange = start...end//Range(start: start, end: end)
            currentText.replaceRange(currentRange, with: text)
            let numberOfCharacters = currentText.characters.count
            if numberOfCharacters > maxNumberOfCharacters {
                didOverflowHandler?(numberOfCharacters)
                return false
            }
        }
        return true
    }
    
    //MARK: private

    func drawPlaceholderView() {
        if text == nil || text.isEmpty {
            if let placeholderView = placeholderView {
                placeholderView.hidden = false
            }
        }else {
            placeholderView?.hidden = true
        }
    }
    
    func adjustTextView(textView: UITextView) {
        if shouldChangeHeightAutomatically {
            let textViewHeight = ceil(textView.frame.height)
            
            DDInputTextView.log.print("textViewHeight: \(textViewHeight) textView: \(textView)")
            
            let attributedText = NSAttributedString(string: textView.text, attributes: textView.typingAttributes)
            
            let boundingRectHeight = ceil(attributedText.boundingRectWithSize(CGSize(width: textView.frame.width, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil).height)
            
            DDInputTextView.log.print("boundingRectHeight: \(boundingRectHeight) lineSpacing: \(lineSpacing) lineHeight: \(lineHeight)")
            
            //numberOfLines * lineHeight + (numberOfLines - 1) * lineSpacing = boundingRectHeight
            let numberOfLines = Int(round((boundingRectHeight + lineSpacing) / (lineHeight + lineSpacing)))
            DDInputTextView.log.print("numberOfLines: \(numberOfLines)")
            
            if boundingRectHeight > textViewHeight {
                //line increased, check if text view needs to be taller
                let maxTextViewHeight = self.maxTextViewHeight
                DDInputTextView.log.print("maxTextViewHeight: \(maxTextViewHeight)")
                if textViewHeight < maxTextViewHeight {
                    //text view can be taller
                    var deltaHeight = boundingRectHeight - textViewHeight
                    DDInputTextView.log.print("deltaHeight: \(deltaHeight)")
                    if textViewHeight + deltaHeight > maxTextViewHeight {
                        //text view height will be greater than maxTextViewHeight, adjust deltaHeight
                        deltaHeight = floor(maxTextViewHeight - textViewHeight)
                    }
                    DDInputTextView.log.print("adjusted deltaHeight: \(deltaHeight)")
                    if deltaHeight > 0 {
                        //do nothing if final deltaHeight == 0
                        height += deltaHeight
//                        textView.height += deltaHeight
                        DDInputTextView.log.print("increase line deltaHeight: \(deltaHeight) text view \(textView)")
                        didDeltaHeightHandler?(deltaHeight)
                    }
                }
            }else if boundingRectHeight < textViewHeight {
                let minTextViewHeight = self.minTextViewHeight
                DDInputTextView.log.print("minTextViewHeight: \(minTextViewHeight)")
                if textViewHeight > minTextViewHeight {
                    //text view can be shorter
                    var deltaHeight = boundingRectHeight - textViewHeight
                    DDInputTextView.log.print("deltaHeight: \(deltaHeight)")
                    if textViewHeight + deltaHeight < minTextViewHeight {
                        //text view height will be less than minTextViewHeight, adjust deltaHeight
                        deltaHeight = ceil(minTextViewHeight - textViewHeight)
                    }
                    DDInputTextView.log.print("adjusted deltaHeight: \(deltaHeight)")
                    if deltaHeight < 0 {
                        //do nothing if final deltaHeight == 0
                        height += deltaHeight
//                        textView.height += deltaHeight
                        DDInputTextView.log.print("decrease line deltaHeight: \(deltaHeight) text view \(textView)")
                        didDeltaHeightHandler?(deltaHeight)
                    }
                }
            }
        }
    }
    
    //MARK: public
    
    func setDefaults() {
        //input text view bar height is 44
        let bgImage = UIImage(namedNoCache: "DDInput.bundle/bg_input_text")?.resizableImage()
        let bgView = UIImageView(image: bgImage)
        backgroundView = bgView
        
        textViewInsets = UIEdgeInsets(top: 13, left: 12, bottom: 9, right: 8)//vertical margin is 13 + 9 = 22
        
        //text view height = fontHeight(18) + lineSpacing(4) = 22
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let textAttributes: [String: AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.systemFontOfSize(15),//font height is 18
        ]
        textView.typingAttributes = textAttributes
        textView.backgroundColor = UIColor.clearColor()
//        textView.backgroundColor = UIColor(ir: 0, ig: 0, ib: 255, alpha: 0.5)
        textView.returnKeyType = .Done
        textView.showsHorizontalScrollIndicator = false
    }
}
