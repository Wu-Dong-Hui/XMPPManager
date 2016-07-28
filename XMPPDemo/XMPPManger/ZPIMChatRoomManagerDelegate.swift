//
//  ZPIMChatRoomManagerDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
/**
 被踢出聊天室的原因
 
 - beRemoved: 被管理员移出聊天室
 - destroyed: 聊天室被销毁
 */
@objc enum ZPIMChatroomBeKickedReason: Int {
    case beRemoved
    case destroyed
}
//MARK: - ZPIMChatChatRoomManagerDelegate
/**
 *  聊天室相关回调
 */
@objc protocol ZPIMChatRoomManagerDelegate: NSObjectProtocol {
    /**
     有用户加入聊天室
     
     - parameter chatRoom: 加入的聊天室
     - parameter userName: 加入者
     */
    optional func didReceiveUserJoinedChatRoom(chatRoom: ZPIMChatRoom, userName: String)
    /**
     有用户离开聊天室
     
     - parameter chatRoom: 离开的聊天室
     - parameter userName: 离开者
     */
    optional func didReceiveUserLeavedChatRoom(chatRoom: ZPIMChatRoom, userName: String)
    /**
     被踢出聊天室
     
     - parameter chatRoom: 被踢出的聊天室
     - parameter reason:   被踢出聊天室的原因
     */
    optional func didReceiveKickedFromChatRoom(chatRoom: ZPIMChatRoom, reason: ZPIMChatroomBeKickedReason)
}