//
//  ZPIMMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
@objc enum ZPIMMessageBodyType: Int {
    case text
    case image
    case video
    case location
    case voice
    case file
    case cmd
    
    var description: String {
        switch self {
        case .text:
          return "text"
        case .image:
            return "image"
        case .video:
            return "video"
        case .location:
            return "location"
        case .voice:
            return "voice"
        case .file:
            return "file"
        case .cmd:
            return "cmd"
        }
    }
}
class ZPIMMessageBody: NSObject {
    var type: ZPIMMessageBodyType = .text

    init(type: ZPIMMessageBodyType) {
        self.type = type
    }
    override var description: String {
        return type.description
    }
}
