//
//  DDSystem.swift
//  Dong
//
//  Created by darkdong on 15/4/9.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDSystem {
    static let statusBarHeight: CGFloat = 20
    static let navigationBarHeight: CGFloat = 44
    static let topBarHeight: CGFloat = statusBarHeight + navigationBarHeight
    static let bottomTabBarHeight: CGFloat = 49
    static let bottomToolBarHeight: CGFloat = 44

    static var scaleX: CGFloat = {
        let screenHeight = UIScreen.mainScreen().bounds.height
        if screenHeight == 667 { //width 375
            //iPhone6: 750 * 1334 = 375x2 * 667x2
            return 375 / 320
        }else if screenHeight == 736 { // width 414
            //iPhone6 Plus: 1242 * 2208 = 414x3 * 736x3
            return 414 / 320
        }else {
            return 1
        }
        }()
    
    static func x(unitX: CGFloat) -> CGFloat {
        return unitX * DDSystem.scaleX
    }
        
    //MARK: version
    static func appVersion() -> String! {
        return CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), "CFBundleShortVersionString") as? String
    }
    
    static func isOperatingSystemAtLeastVersion(version: String) -> Bool {
        return UIDevice.currentDevice().systemVersion.versionGreaterThanOrEqualTo(version)
    }
    
//    static func filesByOrderInDirectory(directory: String) -> [String] {
//        if let files = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory, error: nil) as? [String] {
//            var visibleFiles = files.filter {
//                !$0.hasPrefix(".")
//            }
//            visibleFiles.sort({ (file1, file2) -> Bool in
//                file1 < file2
//            })
//            return visibleFiles
//        }else {
//            return []
//        }
//    }
//    
//    static func filePathForNextOrderInDirectory(directory: String) -> String {
//        var fileNumber = 0
//        let files = filesByOrderInDirectory(directory)
//        if let lastFileName = files.last {
//            if let lastFileNumber = lastFileName.lastPathComponent.stringByDeletingPathExtension.toInt() {
//                fileNumber = lastFileNumber
//            }
//        }
//        let fileName = NSString(format: "%05u.plist", fileNumber)
//        let filePath = directory.stringByAppendingPathComponent(fileName as String)
//        return filePath
//    }
    
    //MARK: - GCD
    static func globalBackgroundQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    }
    
    static func doInMainQueue(closure: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
    
    static func delay(delay:Double, closure:() -> Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //MARK: plist
    static func objectFromPlistFileName(fileName: String!, extName: String = "plist", options: NSPropertyListMutabilityOptions = .Immutable, bundle: NSBundle = NSBundle.mainBundle()) -> AnyObject? {
        if let plistFilePath = bundle.pathForResource(fileName, ofType: extName) {
            if let plistData = NSData(contentsOfFile: plistFilePath) {
                return self.objectFromPlistData(plistData, options: options)
            }
        }
        return nil
    }
    
    static func objectFromPlistFile(filePath: String!, options: NSPropertyListMutabilityOptions = .Immutable) -> AnyObject? {
        if let plistData = NSData(contentsOfFile: filePath) {
            return self.objectFromPlistData(plistData, options: options)
        }
        return nil
    }
    
    static func objectFromPlistData(data: NSData!, options: NSPropertyListMutabilityOptions = .Immutable) -> AnyObject? {
        return try? NSPropertyListSerialization.propertyListWithData(data, options: options, format: nil)
    }
}