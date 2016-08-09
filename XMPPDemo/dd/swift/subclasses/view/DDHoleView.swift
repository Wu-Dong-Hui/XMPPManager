//
//  DDHoleView.swift
//  Dong
//
//  Created by darkdong on 15/9/7.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDHoleView: UIView {
    var holePaths = [UIBezierPath]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opaque = false
        backgroundColor = UIColor(white: 1, alpha: 0.8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        UIColor.clearColor().setFill()
        for holePath in holePaths {
            holePath.fillWithBlendMode(CGBlendMode.Copy, alpha: 1)
        }
    }
}
