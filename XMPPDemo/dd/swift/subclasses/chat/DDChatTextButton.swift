//
//  DDChatTextButton.swift
//  Dong
//
//  Created by darkdong on 15/1/22.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDChatTextButton: DDButton {
    var textView: UITextView!
    
    var attributedText: NSAttributedString {
        get {
            return textView.attributedText
        }
        set {
//            DDLog2.print("attributedText MUST BE EQUAL \(newValue)")
            textView.attributedText = newValue
        }
    }
    
    override var frame: CGRect {
        didSet {
            textView?.frame = frame.rectByEdgeInsets(textViewInsets)
        }
    }
    
    var textViewInsets: UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            textView?.frame = frame.rectByEdgeInsets(textViewInsets)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textViewFrame = frame.rectByEdgeInsets(textViewInsets)
        textView = UITextView(frame: textViewFrame)
//        textView.userInteractionEnabled = false
        textView.backgroundColor = UIColor.clearColor()
        textView.bounces = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        textView.editable = false
//        textView.delegate = self
        addSubview(textView)
    }
}
