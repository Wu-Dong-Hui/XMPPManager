//
//  DDChatImageButton.swift
//  Dong
//
//  Created by darkdong on 15/10/29.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

class DDChatImageButton: DDButton {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //MARK: - public
    
    func prepareForReuse() {
        layer.mask = nil
        setImage(nil, forState: .Normal)
        setBackgroundImage(nil, forState: .Normal)
    }
    
    func setImage(image: UIImage?, style: DDChatImageBubbleStyle, contentMode: UIViewContentMode) {
        if contentMode == .ScaleAspectFill {
            setBackgroundImage(image, forState: .Normal)
        }else {
            setImage(image, forState: .Normal)
        }
        clipsToMaskImage(style.bubbleMaskImage)
    }
}