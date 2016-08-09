//
//  NSObjectExtension.swift
//  Dong
//
//  Created by darkdong on 14-8-1.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation

private var associatedObjectKey = 0
private var selectionKey = 0

extension NSObject {
    class func swiftClassFromString(className: String) -> AnyClass? {
        if let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String {
            let classStringName = "\(appName).\(className)"
            return NSClassFromString(classStringName)
        }
        return nil
    }
    
    class func createObjectFromString(className: String) -> AnyObject? {
        if let objClass: AnyClass = self.swiftClassFromString(className), let objType = objClass as? NSObject.Type {
            return objType.init()
        }
        return nil
    }
    
    var associatedObject: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &associatedObjectKey)
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func className() -> String! {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last
    }
    
    func clone() -> AnyObject? {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        return NSKeyedUnarchiver.unarchiveObjectWithData(data)
    }
}
