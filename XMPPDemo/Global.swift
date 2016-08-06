//
//  Global.swift
//  ZPinBProduct
//
//  Created by Roy on 16/5/16.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation

class Global: NSObject {
    static let sharedInstance = Global()
    private override init() {
        super.init()
    }
    var server: String = "http://localhost:8080/zpim/"
    

}