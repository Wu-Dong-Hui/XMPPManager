//
//  DDHashAlgorithm.swift
//  Dong
//
//  Created by darkdong on 15/1/14.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

enum DDHashAlgorithm {
    typealias HashFunction = (UnsafePointer<Void>, CC_LONG, UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>
    
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    func hashFunction() -> HashFunction {
        switch self {
        case .MD5:
            return CC_MD5
        case .SHA1:
            return CC_SHA1
        case .SHA224:
            return CC_SHA224
        case .SHA256:
            return CC_SHA256
        case .SHA384:
            return CC_SHA384
        case .SHA512:
            return CC_SHA512
        }
    }
}