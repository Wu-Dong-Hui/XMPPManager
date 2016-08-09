//
//  UITextViewExtension.swift
//  Dong
//
//  Created by darkdong on 15/5/27.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

extension UITextView {
    func setupForCell() {
        self.userInteractionEnabled = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.textContainerInset = UIEdgeInsetsZero
        self.textContainer.lineFragmentPadding = 0
    }
    
    func paragraphRects() -> [CGRect] {
        let layoutManager = self.layoutManager
        let textContainer = self.textContainer
        let ranges = self.text.rangesBySeparator("\n")
        var rects: [CGRect] = []
        for range in ranges {
            let rect = layoutManager.boundingRectForGlyphRange(range, inTextContainer: textContainer)
            rects.append(rect)
        }
        return rects
    }
}