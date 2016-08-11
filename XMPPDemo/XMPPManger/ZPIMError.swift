//
//  ZPIMError.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
@objc enum ZPIMErrorCode: Int {
    case success = 0
    
    
    var description: String {
        switch self {
        case .success:
            return "success"
        }
    }
    
}
class ZPIMError: NSObject {
    private (set) var code: Int = 0
    private (set) var desc: String = ""
    
    
    override var description: String {
        return "\(code)" + "\(desc)"
    }
    
    init(code: Int, description: String) {
        self.code = code
        self.desc = description
    }
    class func success() -> ZPIMError {
        return ZPIMError(code: ZPIMErrorCode.success.rawValue, description: ZPIMErrorCode.success.description)
    }
}
