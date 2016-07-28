//
//  ZPIMClientDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
/**
 网络连接状态
 
 - viaWiFi:     WiFi
 - viaWWAN:     WWAN
 - unreachable: 不可用
 */
@objc enum ZPIMNetworkState: Int {
    case viaWiFi
    case viaWWAN
    case unreachable
}
//MARK: - ZPIMClientDelegate
@objc protocol ZPIMClientDelegate: NSObjectProtocol {
    /**
     连接服务器的状态变化时会接收到该回调
     
     有以下几种情况, 会引起该方法的调用:
     1. 登录成功后, 手机无法上网时, 会调用该回调
     2. 登录成功后, 网络状态变化时, 会调用该回调
     
     - parameter state: 当前状态
     */
    optional func didConnectionStateChanged(state: ZPIMNetworkState)
    /**
     自动登录时的回调
     
     - parameter error: 错误信息  error==nil success, otherwise fail
     */
    optional func didAutoLoginWithError(error: ZPIMError?)
    /**
     当前登录账号在其它设备登录时会接收到该回调
     - parameter device: 最新登录的设备
     */
    optional func didLoginFromOtherDevice(device: ZPIMDevice)
    /**
     当前登录账号已经被从服务器端删除时会收到该回调
     
     - parameter error: 移除原因
     */
    optional func didRemoveFromServer(error: ZPIMError)
}