//
//  ZPIMOptions.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
@objc enum ZPIMLogLevel: Int {
    case none
}
class ZPIMOptions: NSObject {
    var enableConsoleLog: Bool = true
    var logLevel: ZPIMLogLevel = .none
    var usingHttps: Bool = true
    var autoLogin: Bool = true
    var deleteMessagesWhenExitGroup: Bool = false
    var deleteMessagesWhenExitChatRoom: Bool = false
    var chatRoomOwnerLeaveAllowed: Bool = false
    var autoAcceptGroupInvitation: Bool = true
    var autoAcceptFriendInvitation: Bool = true
    var enableDeliveryAck: Bool = false
    //private
    private var enableDNSConfig: Bool = false
    private var chatPort: Int = 0
    private var chatServer: String = "http://imserver.zhaopin.com"
    private var restServer: String = "http://imserver.zhaopin.com"
}