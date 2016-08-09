//
//  NSDataExtension.swift
//  Dong
//
//  Created by darkdong on 14/12/29.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation

extension NSData {
    func hexString(isLowercase: Bool = true) -> String {
        let hexString = NSMutableString(capacity: 2 * self.length)
        self.enumerateByteRangesUsingBlock { (bytes, byteRange, stop) -> Void in
            let puint8 = UnsafePointer<UInt8>(bytes)
            let format = isLowercase ? "%02x" : "%02X"
            for i in 0 ..< byteRange.length {
                hexString.appendFormat(format, puint8[i])
            }
        }
        return String(hexString)
    }
    
    func hashByAlgorithm(algorithm: DDHashAlgorithm, isLowercase: Bool = true) -> String {
        let digestLen = algorithm.digestLength()
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        let hashFunction = algorithm.hashFunction()
        hashFunction(self.bytes, CC_LONG(self.length), result)
        
        let hash = NSMutableString()
        let format = isLowercase ? "%02x" : "%02X"
        for i in 0..<digestLen {
            hash.appendFormat(format, result[i])
        }
        result.destroy()
        return String(hash)
    }
    
    func dataByXor(key: NSData) -> NSData {
        let data = NSMutableData(data: self)
        let dataBuffer = UnsafeMutablePointer<Int8>(data.mutableBytes)
        let keyBuffer = UnsafePointer<Int8>(key.bytes)

        for i in 0..<data.length {
            dataBuffer[i] ^= keyBuffer[i % key.length]
        }
        return data
    }
    
    func toString(encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        return String(data: self, encoding: encoding)
    }
}
