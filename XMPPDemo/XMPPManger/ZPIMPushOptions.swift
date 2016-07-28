//
//  ZPIMPushOptions.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
@objc enum ZPIMPushDisplayStyle: Int {
    case none
}
@objc enum ZPIMPushNoDisturbStatus: Int {
    case none
}
class ZPIMPushOptions: NSObject {
    var nickName: String = ""
    var displayStyle: ZPIMPushDisplayStyle = .none
    var noDisturbStatus: ZPIMPushNoDisturbStatus = .none
    var noDisturbStartTime: NSDate!
    var noDisturbEndTime: NSDate!
    
}