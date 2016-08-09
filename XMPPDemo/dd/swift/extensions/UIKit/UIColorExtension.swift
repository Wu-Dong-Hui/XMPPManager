//
//  UIColorExtension.swift
//  Dong
//
//  Created by darkdong on 14/11/21.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

extension UIColor {
    class var clickableColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 0.01)
    }
    
    convenience init(ir: Int, ig: Int, ib: Int, alpha: CGFloat = 1) {
        let red = CGFloat(ir) / 255.0
        let green = CGFloat(ig) / 255.0
        let blue = CGFloat(ib) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(ternary: Int, alpha: CGFloat = 1) {
        let red = CGFloat((ternary & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((ternary & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(ternary & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let nsString = NSString(string: hexString)
        let redStr = nsString.substringWithRange(NSMakeRange(0, 2))
        let greenStr = nsString.substringWithRange(NSMakeRange(2, 2))
        let blueStr = nsString.substringWithRange(NSMakeRange(4, 2))
        var red:CUnsignedInt = 0, green:CUnsignedInt = 0, blue:CUnsignedInt = 0
        NSScanner(string: redStr).scanHexInt(&red)
        NSScanner(string: greenStr).scanHexInt(&green)
        NSScanner(string: blueStr).scanHexInt(&blue)
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}