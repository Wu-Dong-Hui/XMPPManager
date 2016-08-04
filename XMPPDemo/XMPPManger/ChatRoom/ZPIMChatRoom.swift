//
//  ZPIMChatRoom.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMChatRoom: NSObject {
    private (set) var id: String!
    private (set) var subject: String!
    private (set) var desc: String!
    private (set) var owner: String!
    private (set) var occupantCount: Int!
    private (set) var maxOccupantCount: Int!
    private (set) var occupants: Array<AnyObject>!
    
    init(id: String) {
        
    }
}
