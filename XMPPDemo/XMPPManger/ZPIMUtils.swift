//
//  ZPIMUtils.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/2.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation
class ZPIMUtil: NSObject {
    class func convertToZPIMMessage(message: XMPPMessage) -> ZPIMMessage {
        let imMsg = ZPIMMessage()
        let mediaType = message.getMediaType()
        var body: ZPIMMessageBody!
        if mediaType == .text {
            body = ZPIMTextMessageBody(text: message.body())
        } else if mediaType == .image {
            body = ZPIMImageMessageBody(type: .image)
        }
        
        imMsg.from = message.fromStr()
        imMsg.to = message.toStr()
        imMsg.body = body
        return imMsg
    }
    class func convertToXMPPMessage(message: ZPIMMessage) -> XMPPMessage {
        let toJid = XMPPJID.jidWithUser(message.to, domain: ZPIMClient.domain, resource: ZPIMClient.resource)
        
        let xmppMessage = XMPPMessage(type: "chat", to: toJid)
        xmppMessage.addAttributeWithName("from", stringValue: ZPIMClient.sharedClient.getUserName()! + "@\(ZPIMClient.domain)/\(ZPIMClient.resource)")
        xmppMessage.addMediaType(message.body.type)
        if let textBody = message.body as? ZPIMTextMessageBody {
            xmppMessage.addBody(textBody.text)
        } else if let imageBody = message.body as? ZPIMImageMessageBody {
            xmppMessage.addBody(imageBody.reomotePath)
        }
        return xmppMessage
    }
}
