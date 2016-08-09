//
//  UIDeviceExtension.swift
//  Dong
//
//  Created by darkdong on 14/10/24.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

extension UIDevice {
    static func friendlyName() -> String! {
        let hwname = self.hardwareName()
        if hwname.hasPrefix("iPhone") {
            switch hwname {
            case "iPhone8,2":
                return "iPhone 6S Plus"
            case "iPhone8,1":
                return "iPhone 6S"
            case "iPhone7,1":
                return "iPhone 6 Plus"
            case "iPhone7,2":
                return "iPhone 6"
            case "iPhone6,1", "iPhone6,2":
                return "iPhone 5S"
            case "iPhone5,3", "iPhone5,4":
                return "iPhone 5C"
            case "iPhone5,1", "iPhone5,2":
                return "iPhone 5"
            case "iPhone4,1":
                return "iPhone 4S"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":
                return "iPhone 4"
            case "iPhone2,1":
                return "iPhone 3GS"
            case "iPhone1,2":
                return "iPhone 3G"
            case "iPhone1,1":
                return "iPhone"
            default:
                break
            }
        }else if hwname.hasPrefix("iPod") {
            switch hwname {
            case "iPod5,1":
                return "iPod 5G"
            case "iPod4,1":
                return "iPod 4G"
            case "iPod3,1":
                return "iPod 3G"
            case "iPod2,1":
                return "iPod 2G"
            case "iPod1,1":
                return "iPod"
            default:
                break
            }
        }else if hwname.hasPrefix("iPad") {
            switch hwname {
            case "iPad5,3", "iPad5,4":
                return "iPad Air 2"
            case "iPad4,1", "iPad4,2", "iPad4,3":
                return "iPad Air"
            case "iPad3,4", "iPad3,5", "iPad3,6":
                return "iPad 4"
            case "iPad3,1", "iPad3,2", "iPad3,3":
                return "iPad 3"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return "iPad 2"
            case "iPad1,1":
                return "iPad"
            default:
                break
            }
        }else if hwname == "x86_64" || hwname == "i386" {
            return "Simulator"
        }
        return hwname
    }
    
    static func hardwareName() -> String! {
        let name = "hw.machine"
        var size: Int = 0
        sysctlbyname(name, nil, &size, nil, 0)
        let machine = UnsafeMutablePointer<Void>.alloc(Int(size))
        sysctlbyname(name, machine, &size, nil, 0)
        let hwname = NSString(CString: UnsafePointer<Int8>(machine), encoding: NSUTF8StringEncoding)
        machine.dealloc(Int(size))
        return hwname as? String
    }
}