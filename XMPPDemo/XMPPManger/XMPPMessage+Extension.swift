//
//  XMPPMessage+Extension.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/10.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import Foundation

typealias XMPPMessageMediaType = ZPIMMessageBodyType

extension XMPPMessage {
    func addMediaType(type: XMPPMessageMediaType) {
        addAttributeWithName("mediaType", integerValue: type.rawValue)
    }
    func getMediaType() -> XMPPMessageMediaType {
        return XMPPMessageMediaType(rawValue: attributeIntegerValueForName("mediaType"))!
    }
    func isValidMessage() -> Bool {
        if let _ = XMPPMessageMediaType(rawValue: attributeIntegerValueForName("mediaType")) where isMessageWithBody() {
            return true
        }
        return false
    }
}