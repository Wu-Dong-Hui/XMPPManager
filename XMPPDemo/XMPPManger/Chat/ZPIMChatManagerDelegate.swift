//
//  ZPIMChatManagerDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
//MARK: - ZPIMChatManagerDelegate
/**
 *  聊天相关回调
 */
@objc protocol ZPIMChatManagerDelegate: NSObjectProtocol {
    
    /**
     会话列表发生变化
     
     - parameter list: 会话列表<ZPIMConversation>
     */
    optional func didUpdateConversationList(list: Array<ZPIMConversation>)
    /**
     会话列表发生变化
     
     - parameter messages: 消息列表<ZPIMMessage>
     */
    optional func didReceiveMessages(messages: Array<ZPIMMessage>)
    /**
     收到Cmd消息
     
     - parameter messages: Cmd消息列表<ZPIMMessage>
     */
    optional func didReceiveCmdMessages(messages: Array<ZPIMMessage>)
    /**
     收到已读回执
     
     - parameter messages: 已读消息列表<ZPIMMessage>
     */
    optional func didReceiveHasReadAcks(messages: Array<ZPIMMessage>)
    /**
     收到消息送达回执
     
     - parameter messages: 送达消息列表<EMMessage>
     */
    optional func didReceiveHasDelivered(messages: Array<ZPIMMessage>)
    /**
     消息状态发生变化
     
     - parameter message: 状态发生变化的消息
     - parameter error:   出错信息
     */
    optional func didMessagesStatusChanged(message: ZPIMMessage, error: ZPIMError?)
    /**
     消息附件状态发生改变
     
     - parameter message: 附件状态发生变化的消息
     - parameter error:   出错信息
     */
    optional func didMessageAttachmentsStatusChanged(message: ZPIMMessage, error: ZPIMError)
}