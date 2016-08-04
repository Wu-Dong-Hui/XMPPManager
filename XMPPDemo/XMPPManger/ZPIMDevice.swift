//
//  ZPIMDevice.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
@objc enum ZPIMDeviceType: Int {
    case iOS
    case Android
    case WindowsPhone
}
/// 登录设备
class ZPIMDevice: NSObject {
    //MARK: - Private
    private (set) var name: String!
    private (set) var IMEI: String!
    private (set) var type: ZPIMDeviceType = .Android
    
    
    
    init(name: String, IMEI: String, type: ZPIMDeviceType) {
        self.name = name
        self.IMEI = IMEI
        self.type = type
    }
}
