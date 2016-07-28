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
}
class ZPIMMessageBody: NSObject {
    var type: ZPIMMessageBodyType = .text

    init(type: ZPIMMessageBodyType) {
        self.type = type
    }
}
