//
//  CGGeometryExtension.swift
//  dong
//
//  Created by darkdong on 15/2/13.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit
import CoreGraphics

extension CGSize {
    var ceilIntSize: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func scaleToFillSize(size: CGSize) -> CGSize {
        let scale = max(size.width / width, size.height / height)
        return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(scale, scale))
    }
    
    func scaleToFitSize(size: CGSize) -> CGSize {
        let scale = min(size.width / width, size.height / height)
        return CGSizeApplyAffineTransform(self, CGAffineTransformMakeScale(scale, scale))
    }
    
    func sizeByDevice(keepAspectRatio keepAspectRatio: Bool) -> CGSize {
        let deviceWidth = DDSystem.x(width)
        if keepAspectRatio {
            let scale = deviceWidth / width
            return CGSize(width: deviceWidth, height: height * scale)
        }else {
            return CGSize(width: deviceWidth, height: height)
        }
    }
}

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            let x = (2 * newValue.x - width) / 2
            let y = (2 * newValue.y - height) / 2
            origin = CGPoint(x: x, y: y)
        }
    }
    
    func rectByEdgeInsets(insets: UIEdgeInsets) -> CGRect {
        var w = width - insets.left - insets.right
        if w < 0 {
            w = 0
        }
        var h = height - insets.top - insets.bottom
        if h < 0 {
            h = 0
        }
        return CGRect(x: insets.left, y: insets.top, width: w, height: h)
    }
    
    func rectByDevice(keepAspectRatio keepAspectRatio: Bool) -> CGRect {
        let deviceX = DDSystem.x(minX)
        let deviceWidth = DDSystem.x(width)
        if keepAspectRatio {
            let scale = deviceWidth / width
            return CGRect(x: deviceX, y: minY * scale, width: deviceWidth, height: height * scale)
        }else {
            return CGRect(x: deviceX, y: minY, width: deviceWidth, height: height)
        }
    }
}

