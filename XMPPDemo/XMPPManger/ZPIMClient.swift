//
//  ZPIMClient.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

typealias ZPIMBaseCompletion = ((ZPIMError?) -> Void)

class ZPIMClient: NSObject {
    static let sharedClient = ZPIMClient()
    
    private override init() {
        DDLogInfo("init")
    }
    
    private var stream: XMPPStream!
    
    func initialize(options: ZPIMOptions) -> ZPIMError? {
        stream = XMPPStream()
        stream.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
        let jid = XMPPJID.jidWithUser("test1", domain: "127.0.0.1", resource: "zhaopin.com")
        stream.myJID = jid
        
        do {
            try stream.connectWithTimeout(20)
        } catch let err {
            DDLogError("\(err)")
        }
        
        return nil
    }

    
    
    func addDelegate(delegate: ZPIMClientDelegate, queue: dispatch_queue_t) {
        
    }
    func removeDelegate(delegate: ZPIMClientDelegate) {
        
    }
    func register(userName: String, password: String, completion: ZPIMBaseCompletion) {
        
    }
    func login(userName: String, password: String, completion: ZPIMBaseCompletion) {
        
    }
    func logout(completion: ZPIMBaseCompletion) {
        
    }
    func bindDeviceToken(token: String , completion: ZPIMBaseCompletion) {
        
    }
    func getPushOptionsFromServer(completion: ZPIMBaseCompletion) {
        
    }
    func updatePushOptions(completion: ZPIMBaseCompletion) {
        
    }
    func setApnsNickName(name: String, completion: ZPIMBaseCompletion) {
        
    }
    func applicationDidEnterBackground(app: UIApplication) {
        
    }
    func applicationWillEnterForeground(app: UIApplication) {
        
    }
    var version: String {
        return ""
    }
    var currentUserName: String {
        return ""
    }
    var options: ZPIMOptions {
        return ZPIMOptions()
    }
    var pushOptions: ZPIMPushOptions {
        return ZPIMPushOptions()
    }
    var isLoggedin: Bool {
        return false
    }
    var isAutoLogin: Bool {
        return false
    }
    var isConnected: Bool {
        return false
    }
    var chatManager: ZPIMIChatManager {
        return ZPIMChatManager()
    }
    var contactManager: ZPIMIContactManager {
        return ZPIMContactManager()
    }
    var groupManager: ZPIMIGroupManager {
        return ZPIMGroupManager()
    }
    var chatRoomManager: ZPIMIChatChatRoomManager {
        return ZPIMChatRoomManager()
    }
    
}
