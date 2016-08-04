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
    private (set) var id: String!
    private (set) var type: ZPIMConversationType = .chat
    private (set) var unreadMessageCount: Int = 0
    private (set) var latestMessage: ZPIMMessage!
    
    
    var ext: [String: AnyObject]!
    
    
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
