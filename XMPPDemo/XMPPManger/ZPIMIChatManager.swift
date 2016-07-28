//
//  ZPIMIChatManager.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
typealias ZPIMSendMessageProgressCompletion = ((progress: Int) -> (Void))
//success if `message` is NOT nil, fail otherwise; `error` include some info(success or fail)
typealias ZPIMSendMessageCompletion = ((message: ZPIMMessage?, error: ZPIMError) -> (Void))
typealias ZPIMDownloadMessageCompletion = ((message: ZPIMMessage?, error: ZPIMError) -> (Void))
//MARK: - ZPIMIChatManager
/**
 *  聊天相关操作
 */
@objc protocol ZPIMIChatManager: NSObjectProtocol {
    /**
     添加回调代理
     
     - parameter delegate:      要添加的代理
     - parameter delegateQueue: 执行代理方法的队列
     
     */
    func addDelegate(delegate: ZPIMChatManagerDelegate, delegateQueue: dispatch_queue_t)
    /**
     移除回调代理
     
     - parameter delegate: 要移除的代理
     
     */
    func removeDelegate(delegate: ZPIMChatManagerDelegate)
    /**
     获取所有会话，如果内存中不存在会从DB中加载
     
     - returns: 会话列表<ZPIMConversation>
     */
    func getAllConversations() -> Array<ZPIMConversation>
    /**
     从数据库中获取所有的会话，执行后会更新内存中的会话列表
     
     同步方法，会阻塞当前线程
     
     - returns: 会话列表<EMConversation>
     */
    func loadAllConversationFromDB() -> Array<ZPIMConversation>
    /**
     获取一个会话
     
     - parameter conversationId:   会话ID
     - parameter type:             会话类型
     - parameter createIfNotExist: 如果不存在是否创建
     
     - returns: 会话实例
     */
    func getConversation(conversationId: String, type: ZPIMConversationType, createIfNotExist: Bool) -> ZPIMConversation
    /**
     删除会话
     
     - parameter conversationId: 会话ID
     - parameter deleteMessages: 是否删除会话中的消息
     
     - returns: 是否成功
     */
    func deleteConversation(conversationId: String, deleteMessages: Bool) -> Bool
    /**
     删除一组会话
     
     - parameter conversationIds: 会话列表<ZPIMConversation>
     - parameter deleteMessages:  是否删除会话中的消息
     
     - returns: 是否成功
     */
    func deleteConversations(conversationIds: Array<ZPIMConversation>, deleteMessages: Bool) -> Bool
    /**
     导入一组会话到DB
     
     - parameter conversations: 会话列表<ZPIMConversation>
     
     - returns: 是否成功
     */
    func importConversations(conversations: Array<ZPIMConversation>) -> Bool
    /**
     获取消息附件路径, 存在这个路径的文件，删除会话时会被删除
     
     - parameter path: 会话ID
     
     - returns: 附件路径
     */
    func getMessageAttachmentPath(path: String) -> String
    /**
     导入一组消息到DB
     
     - parameter messages: 消息列表<ZPIMMessage>
     
     - returns:  是否成功
     */
    func importMessages(messages: Array<ZPIMMessage>) -> Bool
    /**
     更新消息到DB
     
     - parameter message: 消息
     
     - returns: 是否成功
     */
    func updateMessage(message: ZPIMMessage) -> Bool
    /**
     发送消息已读回执
     
     异步方法
     
     - parameter message: 消息
     */
    func asyncSendReadAckForMessage(message: ZPIMMessage)
    /**
     发送消息
     
     - parameter message:    消息
     - parameter progress:   附件上传进度回调block
     - parameter completion: 发送完成回调block
     */
    func asyncSendMessage(message: ZPIMMessage, progress: ZPIMSendMessageProgressCompletion?, completion: ZPIMSendMessageCompletion?)
    /**
     重发送消息
     
     异步方法
     
     - parameter message:    消息
     - parameter progress:   附件上传进度回调block
     - parameter completion: 发送完成回调block
     */
    func asyncResendMessage(message: ZPIMMessage, progress: ZPIMSendMessageProgressCompletion?, completion: ZPIMSendMessageCompletion?)
    /**
     下载缩略图（图片消息的缩略图或视频消息的第一帧图片），自动下载缩略图，所以除非自动下载失败，用户不需要自己下载缩略图
     
     异步方法
     
     - parameter message:    消息
     - parameter progress:   附件下载进度回调block
     - parameter completion: 下载完成回调block
     */
    func asyncDownloadMessageThumbnail(message: ZPIMMessage, progress: ZPIMSendMessageProgressCompletion?, completion: ZPIMDownloadMessageCompletion?)
    /**
     下载消息附件（语音，视频，图片原图，文件），自动下载语音消息，所以除非自动下载语音失败，用户不需要自动下载语音附件
     
     异步方法
     
     - parameter message:    消息
     - parameter progress:   附件下载进度回调block
     - parameter completion: 下载完成回调block
     */
    func asyncDownloadMessageAttachments(message: ZPIMMessage, progress: ZPIMSendMessageProgressCompletion?, completion: ZPIMDownloadMessageCompletion?)
}