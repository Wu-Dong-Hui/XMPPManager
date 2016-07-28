//
//  ZPImConversation.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
@objc enum ZPIMConversationType: Int {
    case chat
    case groupChat
    case roomChat
}

class ZPIMConversation: NSObject {
    private var _id: String!
    private var _type: ZPIMConversationType = .chat
    private var _unreadMessageCount: Int = 0
    private var _latestMessage: ZPIMMessage!
    
    var id: String {
        return _id
    }
    var type: ZPIMConversationType {
        return _type
    }
    var unreadMessageCount: Int {
        return _unreadMessageCount
    }
    var ext: [String: AnyObject]!
    var latestMessage: ZPIMMessage {
        return _latestMessage
    }
    
    func appendMessage(message: ZPIMMessage) -> Bool {
        return false
    }
    func deleteMessage(message: ZPIMMessage) -> Bool {
        return false
    }
    func deleteAllMessage() -> Bool {
        return false
    }
    func updateMessage(message: ZPIMMessage) -> Bool {
        return false
    }
    func markMessageAsRead(messageId: String) -> Bool {
        return false
    }
    func markAllMessageAsRead() -> Bool {
        return false
    }
    
    func loadMessage(messageId: String) -> ZPIMMessage {
        return ZPIMMessage()
    }
    
}
