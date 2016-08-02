//
//  ZPIMChatRoomManager.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMChatRoomManager: NSObject, ZPIMIChatChatRoomManager {
    func addDelegate(delegate: ZPIMChatRoomManagerDelegate, queue: dispatch_queue_t) {
        
    }
    func removeDelegate(delegate: ZPIMChatRoomManagerDelegate) {
        
    }
    func getAllChatRoomFromServer(error: UnsafePointer<ZPIMError>) -> Array<ZPIMChatRoom>! {
        return Array<ZPIMChatRoom>()
    }
    func joinChatRoom(chatRoomId: String, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom! {
        return ZPIMChatRoom(id: "")
    }
    func leaveChatRoom(chatRoomId: String, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom! {
        return ZPIMChatRoom(id: "")
    }
    func fetchChatRoomInfo(chatRoomId: String, includeMemberList: Bool, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom! {
        return ZPIMChatRoom(id: "")
    }
    func asyncGetAllChatRoom(completion: ZPIMChatRoomCompletion?) {
        
    }
    func asyncJoinChatRoom(chatRoomId: String, completion: ZPIMChatRoomCompletion?) {
        
    }
    func asyncLeaveChatRoom(chatRoomId: String, completion: ZPIMChatRoomCompletion?) {
        
    }
    func asyncFetchChatRoomInfo(chatRoomId: String, includeMemberList: Bool, completion: ZPIMChatRoomCompletion?) {
        
    }
}
