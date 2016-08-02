//
//  ZPIMError.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMError: NSObject {
    private var _code: Int = 0
    private var _description: String = ""
    
    var code: Int {
        return 0
    }
    override var description: String {
        return "\(_code)" + "\(_description)"
    }
    
    init(code: Int, description: String) {
        _code = code
        _description = description
    }
}
