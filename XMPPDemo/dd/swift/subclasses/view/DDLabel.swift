//
//  DDLabel.swift
//  snowlotus
//
//  Created by darkdong on 15/8/14.
//  Copyright (c) 2015年 Pixshow. All rights reserved.
//

import UIKit

class DDLabel: UILabel {
    var contentInsets: UIEdgeInsets = UIEdgeInsetsZero
    
    override func drawTextInRect(rect: CGRect) {
        let contentRect = UIEdgeInsetsInsetRect(rect, contentInsets)
        super.drawTextInRect(contentRect)
    }
}
