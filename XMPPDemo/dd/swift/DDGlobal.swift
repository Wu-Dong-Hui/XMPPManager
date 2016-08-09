//
//  DDGlobal.swift
//  Dong
//
//  Created by darkdong on 14/10/28.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit
import AssetsLibrary

class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}
//class Stuff {}
//var weakly : [Weak<Stuff>] = [Weak(value: Stuff()), Weak(value: Stuff())]

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    if let mutableLeft = left as? NSMutableAttributedString {
        mutableLeft.appendAttributedString(right)
        return mutableLeft
    }else {
        let mutableString: NSMutableAttributedString
        mutableString = NSMutableAttributedString(attributedString: left)
        mutableString.appendAttributedString(right)
        return mutableString
    }
}

func + (left: NSData, right: NSData) -> NSData {
    if let mutableLeft = left as? NSMutableData {
        mutableLeft.appendData(right)
        return mutableLeft
    }else {
        let mutableData: NSMutableData
        mutableData = NSMutableData(data: left)
        mutableData.appendData(right)
        return mutableData
    }
}

struct DDEdgeInsets {
    static let Zero = DDEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    static let Nil = DDEdgeInsets(top: nil, left: nil, bottom: nil, right: nil)
    
    var top: CGFloat?
    var left: CGFloat?
    var bottom: CGFloat?
    var right: CGFloat?
    
    init(top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

struct DDLine {
    var startPoint: CGPoint
    var endPoint: CGPoint
    
    var dx: CGFloat {
        return endPoint.x - startPoint.x
    }
    
    var dy: CGFloat {
        return endPoint.y - startPoint.y
    }
}

struct DDArc {
    var center: CGPoint
    var radius: CGFloat
    var startAngle: CGFloat
    var endAngle: CGFloat
    var clockwise: Bool
    
    var bezierPath: UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    }
}

protocol DDCellGeometryFlexible {
    func calculateGeometry(forced: Bool)
}

protocol DDCellReusable {
    func reuseWithModel(model: AnyObject)
}

protocol DDCellModel {
    static var cellClass: AnyClass {get}
    static var cellReuseIdentifier: String {get}
}
