//
//  ZPIMTextMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMTextMessageBody: ZPIMMessageBody {
    private var _text: String!
    var text: String {
        return _text
    }
    init(text: String) {
        super.init(type: .text)
    }
    
}
