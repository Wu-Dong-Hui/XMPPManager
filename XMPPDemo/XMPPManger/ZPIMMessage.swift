//
//  ZPIMMessage.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
@objc enum ZPIMMessageStatus: Int {
    case pending
    case delivering
    case successed
    case failed
}
@objc enum ZPIMMessageDirection: Int {
    case send
    case receive
}
@objc enum ZPIMMessageType: Int {
    case chat
    case groupChat
    case roomChat
    
    var description: String {
        switch self {
        case .chat:
            return "chat"
        case .groupChat:
            return "groupChat"
        case .roomChat:
            return "roomChat"
            
        }
    }
}
class ZPIMMessage: NSObject {
    var id: String!
    var conversationId: String!
    var direction: ZPIMMessageDirection = .receive
    var from: String!
    var to: String!
    var serverTimeStamp: Int64!
    var localTimeStamp: Int64!
    var chatType: ZPIMMessageType = .chat
    var status: ZPIMMessageStatus = .pending
    var isReadAcked: Bool = false
    var isDeliverAcked: Bool = false
    var isRead: Bool = false
    var body: ZPIMMessageBody!
    var ext: [String: AnyObject]?
    override init() {
        
    }
    init(conversationId: String, from: String, to: String, body: ZPIMMessageBody, ext: [String: AnyObject]?) {
        self.conversationId = conversationId
        self.from = from
        self.to = to
        self.body = body
        self.ext = ext
    }
    override var description: String {
        return "\(from)->\(to): \(body.description)"
    }
    
}
