//
//  NSURLExtension.swift
//  Dong
//
//  Created by darkdong on 15/3/5.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

extension NSURL {
    static func URLForDirectory(directory: NSSearchPathDirectory) -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(directory, inDomains: .UserDomainMask) 
        return urls[0]
    }
    
    var stringWithMD5: String? {
        return absoluteString.hashByAlgorithm(.MD5)
    }
    
    var queryDictionary: [String: String] {
        var dictionary = [String: String]()
        if let components = query?.componentsSeparatedByString("&") {
            for kvEquation in components {
                let keyValue = kvEquation.componentsSeparatedByString("=")
                let key = keyValue[0].stringByRemovingPercentEncoding
                let value = keyValue[1].stringByRemovingPercentEncoding
                dictionary[key!] = value
            }
        }
        return dictionary
    }
    
    func URLByReplacingWithPathExtension(pathExtension: String) -> NSURL {
        if let urlWithoutExt = URLByDeletingPathExtension {
            return urlWithoutExt.URLByAppendingPathExtension(pathExtension)
        }
        return self
    }
    
    func isFileExist() -> Bool {
        if let path = self.path {
            return NSFileManager.defaultManager().fileExistsAtPath(path)
        }else {
            return false
        }
    }
    
    func createDirectory() -> NSURL {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(self, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        return self
    }
    
    func removeAllFiles() {
        let manager = NSFileManager.defaultManager()
        if let fileURLs = (try? manager.contentsOfDirectoryAtURL(self, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)) {
            for fileURL in fileURLs {
                do {
                    try manager.removeItemAtURL(fileURL)
                } catch _ {
                }
            }
        }
    }
}