//
//  ZPIMError.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

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
}
