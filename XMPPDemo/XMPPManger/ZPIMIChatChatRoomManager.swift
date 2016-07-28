//
//  ZPIMIChatChatRoomManager.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
//MARK: - ZPIMIChatChatRoomManager
/**
 *  聊天室相关操作
 */
//success if `chatRoom` is NOT nil, fail otherwise; `error` include some info(success or fail)
typealias ZPIMChatRoomCompletion = ((chatRoom: ZPIMChatRoom, error: ZPIMError) -> (Void))
@objc protocol ZPIMIChatChatRoomManager: NSObjectProtocol {
    //MARK - Delegate
    /**
     添加回调代理
     
     - parameter delegate: 要添加的代理
     - parameter queue:    添加回调代理
     
     */
    func addDelegate(delegate: ZPIMChatRoomManagerDelegate, queue: dispatch_queue_t)
    /**
     移除回调代理
     
     - parameter delegate: 要移除的代理
     */
    func removeDelegate(delegate: ZPIMChatRoomManagerDelegate)
    //MARK: - sync method
    /**
     从服务器获取所有的聊天室
     
     同步方法，会阻塞当前线程
     
     - parameter error: 出错信息
     
     - returns: 聊天室列表<ZPIMChatRoom>
     */
    func getAllChatRoomFromServer(error: UnsafePointer<ZPIMError>) -> Array<ZPIMChatRoom>!
    /**
     加入聊天室
     
     同步方法，会阻塞当前线程
     
     - parameter chatRoomId: 聊天室的ID
     - parameter error:      出错信息
     
     - returns: 所加入的聊天室
     */
    func joinChatRoom(chatRoomId: String, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom!
    /**
     退出聊天室
     
     同步方法，会阻塞当前线程
     
     - parameter chatRoomId: 聊天室的ID
     - parameter error:      出错信息
     
     - returns: 退出的聊天室, 失败返回nil
     */
    func leaveChatRoom(chatRoomId: String, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom!
    /**
     获取聊天室详情
     
     同步方法，会阻塞当前线程
     
     - parameter chatRoomId:        聊天室的ID
     - parameter includeMemberList: 是否获取成员列表
     - parameter error:             出错信息
     
     - returns: 聊天室
     */
    func fetchChatRoomInfo(chatRoomId: String, includeMemberList: Bool, error: UnsafePointer<ZPIMError>) -> ZPIMChatRoom!
    //MARK: - async method
    /**
     从服务器获取所有的聊天室
     
     - parameter completion: 回调信息
     */
    func asyncGetAllChatRoom(completion: ZPIMChatRoomCompletion?)
    /**
     加入聊天室
     
     - parameter chatRoomId: 聊天室的ID
     - parameter completion: 回调信息
     */
    func asyncJoinChatRoom(chatRoomId: String, completion: ZPIMChatRoomCompletion?)
    /**
     退出聊天室
     
     - parameter chatRoomId: 聊天室的ID
     - parameter completion: 回调信息
     */
    func asyncLeaveChatRoom(chatRoomId: String, completion: ZPIMChatRoomCompletion?)
    /**
     获取聊天室详情
     
     - parameter chatRoomId:        聊天室的ID
     - parameter includeMemberList: 是否获取成员列表
     - parameter completion:        回调信息
     */
    func asyncFetchChatRoomInfo(chatRoomId: String, includeMemberList: Bool, completion: ZPIMChatRoomCompletion?)
}