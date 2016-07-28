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
    private var _name: String!
    private var _IMEI: String!
    private var _type: ZPIMDeviceType = .Android
    
    var name: String {
        return _name
    }
    var IMEI: String {
        return _IMEI
    }
    var type: ZPIMDeviceType {
        return _type
    }
    
    init(name: String, IMEI: String, type: ZPIMDeviceType) {
        _name = name
        _IMEI = IMEI
        _type = type
    }
}
