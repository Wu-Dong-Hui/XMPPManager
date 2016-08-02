//
//  ZPIMChatRoom.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMChatRoom: NSObject {
    private var _id: String!
    private var _subject: String!
    private var _description: String!
    private var _owner: String!
    private var _occupantCount: Int!
    private var _maxOccupantCount: Int!
    private var _occupants: Array<AnyObject>!
    
    init(id: String) {
        
    }
    var id: String {
        return _id
    }
    var subject: String {
        return _subject
    }
    override var description: String {
        return _description
    }
    var owner: String {
        return _owner
    }
    var occupantCount: Int {
        return _occupantCount
    }
    var maxOccupantCount: Int {
        return _maxOccupantCount
    }
    var occupants: Array<AnyObject> {
        return _occupants
    }
}
