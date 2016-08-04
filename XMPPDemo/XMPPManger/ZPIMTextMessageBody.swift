//
//  ZPIMTextMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMTextMessageBody: ZPIMMessageBody {
    private (set) var text: String!
    
    init(text: String) {
        super.init(type: .text)
        self.text = text
    }
    override var description: String {
        return super.description + " : " + text
    }
}
