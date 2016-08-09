//
//  StringExtension.swift
//  Dong
//
//  Created by darkdong on 14/11/1.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

extension String {
    func toFloat() -> Float {
        return NSString(string: self).floatValue
    }
    
    func toDouble() -> Double {
        return NSString(string: self).doubleValue
    }
    
    subscript (i: Int) -> String {
        return String(Array(self.characters)[i])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = startIndex.advancedBy(r.endIndex)
        return substringWithRange(start...end)
    }
    
    func stringWithLastNCharacters(n: Int) -> String {
        return self.substringWithRange(self.endIndex.advancedBy(-n)...self.endIndex)
    }
    /*
    msg = ""
    MD5:    d41d8cd98f00b204e9800998ecf8427e
    SHA1:   da39a3ee5e6b4b0d3255bfef95601890afd80709
    SHA224: d14a028c2a3a2bc9476102bb288234c415a2b01f828ea62ac5b3e42f
    SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
    SHA384: 38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b
    SHA512: cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
    */
    func hashByAlgorithm(algorithm: DDHashAlgorithm, isLowercase: Bool = true) -> String {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        let hashFunction = algorithm.hashFunction()
        hashFunction(str!, strLen, result)
        
        let hash = NSMutableString()
        let format = isLowercase ? "%02x" : "%02X"
        for i in 0..<digestLen {
            hash.appendFormat(format, result[i])
        }
        result.destroy()
        return String(hash)
    }
    
    func hmacByAlgorithm(algorithm: DDHashAlgorithm, key: String, isLowercase: Bool = true) -> String {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        let objcKey = key as NSString
        let keyStr = objcKey.cStringUsingEncoding(NSUTF8StringEncoding)
        let keyLen = objcKey.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        
        CCHmac(algorithm.toCCHmacAlgorithm(), keyStr, keyLen, str!, strLen, result)
        
        let hash = NSMutableString()
        let format = isLowercase ? "%02x" : "%02X"
        for i in 0..<digestLen {
            hash.appendFormat(format, result[i])
        }
        
        result.destroy()
        return String(hash)
    }
    
    func versionGreaterThanOrEqualTo(otherVersion: String) -> Bool {
        let result = self.compare(otherVersion, options: .NumericSearch)
        return .OrderedDescending == result || .OrderedSame == result
    }
    
    static func stringFromJSON(json: AnyObject, options: NSJSONWritingOptions = NSJSONWritingOptions()) -> String? {
        if let jsonData = try? NSJSONSerialization.dataWithJSONObject(json, options: options) {
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String
        }
        return nil
    }
    
    func JSON(options: NSJSONReadingOptions = NSJSONReadingOptions()) -> AnyObject? {
        if let data = self.UTF8Data {
            if let jsonObject: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: options) {
                return jsonObject
            }
        }
        return nil
    }
    
    func heightForWidth(constraintWidth: CGFloat, attributes: [String: AnyObject]!) -> CGFloat {
        let attrString = NSAttributedString(string: self, attributes: attributes)
        let constraintSize = CGSize(width: constraintWidth, height: CGFloat.max)
        let boundingRect = attrString.boundingRectWithSize(constraintSize, options: .UsesLineFragmentOrigin, context: nil)
        return ceil(boundingRect.height)
    }
    
    func rangesBySeparator(separator: Character) -> [NSRange] {
        let strings = self.characters.split { (char) -> Bool in
            return char == separator
        }.map { String($0) }
        
        var ranges: [NSRange] = []
        var position = 0
        for string in strings {
            let length = string.characters.count
            let range = NSMakeRange(position, length)
            ranges.append(range)
            position += length + 1
        }
        return ranges
    }
    
    //raw string format should be:
    //"to the left\tto the right\nleft again\tright again"
    //result is:
    //to the left       to the right
    //left again         right again
//    func attributedStringForLeftRightLayout(width width: CGFloat, var attributes: [NSObject: AnyObject]!) -> NSAttributedString {
//        func createTabParagraphStyle() -> NSMutableParagraphStyle {
//            let paragraph = NSMutableParagraphStyle()
//            let tab = NSTextTab(textAlignment: .Center, location: width, options: nil)
//            paragraph.tabStops = [tab]
//            return paragraph
//        }
//        if attributes == nil {
//            let paragraph = createTabParagraphStyle()
//            attributes = [
//                NSParagraphStyleAttributeName: paragraph
//            ]
//        }else {
//            if let paragraph = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle {
//                let tab = NSTextTab(textAlignment: .Center, location: width, options: nil)
//                paragraph.tabStops = [tab]
//            }else {
//                let paragraph = createTabParagraphStyle()
//                attributes[NSParagraphStyleAttributeName] = paragraph
//            }
//        }
//        return NSMutableAttributedString(string: self, attributes: attributes)
//    }
    
    var UTF8Data: NSData? {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
    }    
}