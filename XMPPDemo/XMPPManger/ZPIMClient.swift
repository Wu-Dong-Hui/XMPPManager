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
    static let domain: String = "127.0.0.1"
    static let resource: String = "zhaopin.com"
    
    private override init() {
        DDLogInfo("init")
    }
    
    private (set) var stream: XMPPStream!
    
    func initialize(options: ZPIMOptions) -> ZPIMError? {
        stream = XMPPStream()
        stream.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
        
        chatManager = ZPIMChatManager()
        
        stream.addDelegate(chatManager, delegateQueue: dispatch_get_global_queue(0, 0))
        
        
        //register extension
        let reconnect = XMPPReconnect(dispatchQueue: dispatch_get_global_queue(0, 0))
        reconnect.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
        stream.registerModule(reconnect)
        
        return nil
    }

    private func connect(timeout: NSTimeInterval) {
        
    }
    private func connect(timeout: NSTimeInterval, user: String, password: String) {
        let jid = XMPPJID.jidWithUser(user, domain: ZPIMClient.domain, resource: ZPIMClient.resource)
        stream.myJID = jid
        if stream.isConnected() {
            stream.disconnect()
        }
        do {
            try stream.connectWithTimeout(timeout)
        } catch let err {
            DDLogError("\(err)")
        }
    }
    
    func addDelegate(delegate: ZPIMClientDelegate, queue: dispatch_queue_t) {
        
    }
    func removeDelegate(delegate: ZPIMClientDelegate) {
        
    }
    
    func register(userName: String, password: String, completion: ZPIMBaseCompletion?) {
        
    }
    private var loginCompletion: ZPIMBaseCompletion?
    
    func login(userName: String, password: String, completion: ZPIMBaseCompletion?) {
        setUserName(userName)
        setPassword(password)
        connect(30, user: userName, password: password)
        loginCompletion = completion
    }
    func logout(completion: ZPIMBaseCompletion?) {
        
    }
    func bindDeviceToken(token: String , completion: ZPIMBaseCompletion?) {
        
    }
    func getPushOptionsFromServer(completion: ZPIMBaseCompletion?) {
        
    }
    func updatePushOptions(completion: ZPIMBaseCompletion?) {
        
    }
    func setApnsNickName(name: String, completion: ZPIMBaseCompletion?) {
        
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
    private (set) var isLoggedin: Bool = false

    var isAutoLogin: Bool {
        return false
    }
    var isConnected: Bool {
        return false
    }
    private (set) var chatManager: ZPIMIChatManager!
    
    private (set) var contactManager: ZPIMIContactManager!
    
    private (set) var groupManager: ZPIMIGroupManager!
    
    private (set) var chatRoomManager: ZPIMChatRoomManager!
    
    func sendElement(element: XMPPElement) {
        stream.sendElement(element)
    }
}
//MARK: - XMPPStreamDelegate
extension ZPIMClient: XMPPStreamDelegate {
    func xmppStreamDidConnect(sender: XMPPStream!) {
        guard let pw = getPassword() else {
            DDLogError("password do NOT exist")
            return
        }
        do {
            try sender.authenticateWithPassword(pw)
        } catch let err {
            DDLogError("auth error: \(err)")
        }
    }
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        //        DDLogInfo("socketDidConnect \(sender.hostPort)  \(NSString(data: socket.localAddress, encoding: NSUTF8StringEncoding))")
    }
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        let p = XMPPPresence(type: "available")
        sender.sendElement(p)
        loginCompletion?(nil)
        isLoggedin = true
    }
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        DDLogError("\(error)")
        loginCompletion?(ZPIMError(code: -1, description: error.description()))
        isLoggedin = false
    }
    func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        
    }
    
    //MARK: - receive message
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        
        
    }
    func xmppStream(sender: XMPPStream!, willReceiveMessage message: XMPPMessage!) -> XMPPMessage! {
        //这里可以做一些过滤
        return message
    }
    
    //MARK: - send message
    func xmppStream(sender: XMPPStream!, willSendMessage message: XMPPMessage!) -> XMPPMessage! {
        //这里可以做一些过滤
        return message
    }
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        
    }
    
    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        DDLogError(error.description)
    }
}
//MARK: - XMPPReconnectDelegate
extension ZPIMClient: XMPPReconnectDelegate {
    func xmppReconnect(sender: XMPPReconnect!, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        
    }
    func xmppReconnect(sender: XMPPReconnect!, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        if Int(connectionFlags) == kSCNetworkFlagsReachable {
            return true
        }
        return false
    }
}
//MARK: - user
extension ZPIMClient {
    func setUserName(name: String) {
        setUserDefault(name, key: "name")
    }
    func getUserName() -> String? {
        return getUserDefault("name") as? String
    }
    func setPassword(password: String) {
        setUserDefault(password, key: "password")
    }
    func getPassword() -> String? {
        return getUserDefault("password") as? String
    }
    private func setUserDefault(value: AnyObject, key: String) {
        let d = NSUserDefaults.standardUserDefaults()
        d.setObject(value, forKey: key)
        d.synchronize()
    }
    private func getUserDefault(key: String) -> AnyObject? {
        let d = NSUserDefaults.standardUserDefaults()
        return d.valueForKey(key)
    }
    
}