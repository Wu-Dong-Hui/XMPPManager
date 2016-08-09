//
//  UIButtonExtension.swift
//  Dong
//
//  Created by darkdong on 15/3/13.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

extension UIButton {
    func layoutContentVertically(spacing: CGFloat = 0) {
        if let imageSize = self.imageView?.size, let textSize = self.titleLabel?.size {
            let contentHeight = imageSize.height + textSize.height + spacing
            self.imageEdgeInsets = UIEdgeInsetsMake(0, textSize.width, contentHeight - imageSize.height, 0)
            self.titleEdgeInsets = UIEdgeInsetsMake(contentHeight - textSize.height, 0, 0, imageSize.width)
        }
    }
    
    func layoutContentLeftmost() {
        var contentWidth: CGFloat = 0
        
        if let imageWidth = self.imageView?.size.width {
            contentWidth += imageWidth + self.imageEdgeInsets.left + self.imageEdgeInsets.right
        }
        if let textWidth = self.titleLabel?.size.width {
            contentWidth += textWidth + self.titleEdgeInsets.left + self.titleEdgeInsets.right
        }
        //TODO: if there is insets, frame.size.width - contentWidth is not the leftmost exactly, need to revise in future
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, self.frame.size.width - contentWidth)
    }
    
    func layoutContentRightmost() {
        var contentWidth: CGFloat = 0
        
        if let imageWidth = self.imageView?.size.width {
            contentWidth += imageWidth + self.imageEdgeInsets.left + self.imageEdgeInsets.right
        }
        if let textWidth = self.titleLabel?.size.width {
            contentWidth += textWidth + self.titleEdgeInsets.left + self.titleEdgeInsets.right
        }
        //TODO: if there is insets, frame.size.width - contentWidth is not the leftmost exactly, need to revise in future
        self.contentEdgeInsets = UIEdgeInsetsMake(0, self.frame.size.width - contentWidth, 0, 0)
    }
}