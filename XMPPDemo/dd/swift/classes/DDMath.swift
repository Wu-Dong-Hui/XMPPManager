//
//  DDMath.swift
//  Dong
//
//  Created by darkdong on 15/11/11.
//  Copyright © 2015年 Dong. All rights reserved.
//

import CoreGraphics

protocol DDNumericType: Equatable, Comparable {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    func %(lhs: Self, rhs: Self) -> Self
}
extension CGFloat: DDNumericType { }
extension Double : DDNumericType { }
extension Float  : DDNumericType { }
extension Int    : DDNumericType { }

class DDMath {
    //x - x1 / x2 - x1 = y - y1 / y2 - y1
    //y = y1 + (x - x1) * (y2 - y1) / (x2 - x1)
    static func similarY< T: DDNumericType >(x1 x1: T, x: T, x2: T, y1: T, y2: T) -> T {
        if x1 == x2 {
            return y1
        }else {
            return y1 + (x - x1) * (y2 - y1) / (x2 - x1)
        }
    }
}
