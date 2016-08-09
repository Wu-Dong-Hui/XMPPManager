//
//  UIScrollViewExtension.swift
//  Dong
//
//  Created by darkdong on 15/2/15.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToTopAnimated(animated: Bool) {
        self.setContentOffset(CGPoint(x: self.contentOffset.x, y: 0), animated: animated)
    }
    
    func scrollToBottomAnimated(animated: Bool) {
        let diff = self.contentSize.height + self.contentInset.bottom - self.height
        if (diff > 0) {
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: diff), animated: animated)
        }
    }
    
    func scrollRectToVisibleCenter(rect: CGRect, animated: Bool) {
        let dx = (self.width - rect.width) / 2
        let dy = (self.height - rect.height) / 2
        let centerRect = CGRectInset(rect, -dx, -dy)
        self.scrollRectToVisible(centerRect, animated: animated)
    }
    
    func pageIndex() -> Int {
        return Int(self.contentOffset.x / self.frame.width)
    }
    
    func scrollToPreviousPage(animated: Bool) {
        var x = self.contentOffset.x - self.width
        if x < 0 {
            x = 0
        }
        self.scrollRectToVisible(CGRect(x: x, y: 0, width: self.width, height: self.height), animated: animated)
    }
    
    func scrollToNextPage(animated: Bool) {
        var x = self.contentOffset.x + self.frame.width
        if x > self.contentSize.width {
            x = self.contentSize.width
        }
        self.scrollRectToVisible(CGRect(x: x, y: 0, width: self.width, height: self.height), animated: animated)
    }
    
    func setContentOffsetWithDelta(deltaPoint: CGPoint, animated: Bool, shouldCheckBounary: Bool = true) {
        var newContentOffset = contentOffset
        newContentOffset.x += deltaPoint.x
        newContentOffset.y += deltaPoint.y
        if shouldCheckBounary {
            let minX: CGFloat = contentInset.left
            if newContentOffset.x < minX {
                newContentOffset.x = minX
            }
            let maxX = contentSize.width - frame.width + contentInset.right
            if newContentOffset.x > maxX {
                newContentOffset.x = maxX
            }
            let minY: CGFloat = -contentInset.top
            if newContentOffset.y < minY {
                newContentOffset.y = minY
            }
            let maxY = contentSize.height - frame.height + contentInset.bottom
            if newContentOffset.y > maxY {
                newContentOffset.y = maxY
            }
        }
        setContentOffset(newContentOffset, animated: animated)
    }
}
