//
//  ZPIMClient+XMPP.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/28.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation

//xmpp
extension ZPIMClient: XMPPStreamDelegate {
    func xmppStreamDidConnect(sender: XMPPStream!) {
        DDLogInfo("xmppStreamDidConnect")
        do {
            try sender.authenticateWithPassword("admin")
        } catch let err {
            DDLogError("\(err)")
        }
    }
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        DDLogInfo("\(sender.hostPort)  \(socket.localAddress)")
        DDLogInfo("socketDidConnect")
        
    }
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        DDLogInfo("")
        let p = XMPPPresence(type: "available")
        sender.sendElement(p)
    }
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        DDLogInfo("\(error.attributes())")
    }
    func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        DDLogInfo("\(presence.type())")
    }
}