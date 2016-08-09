//
//  DDLog2.swift
//  Dong
//
//  Created by darkdong on 15/3/12.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

class DDLog2 {
    var enabled: Bool = true
    
    static let sharedLog = DDLog2()
    
    class var sharedLogEnabled: Bool {
        get {
            return sharedLog.enabled
        }
        set {
            sharedLog.enabled = newValue
        }
    }
    
    class func log(format: String, _ args: CVarArgType = []) {
        sharedLog.log(format, args)
    }
    
    class func print<T>(object: T) {
        sharedLog.print(object)
    }
    
    func log(format: String, _ args: CVarArgType = []) {
        if enabled {
            NSLog(format, args)
        }
    }
    
    func print<T>(object: T) {
        if enabled {
            Swift.print(object)
        }
    }
}