//
//  ZPIMGroup.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMGroup: NSObject {
    private (set) var groupId: String
    
    init(id: String) {
        groupId = id
    }
    
    
    var subject: String {
        return ""
    }
    var bans: Array<AnyObject> {
        return Array()
    }
    var isBlocked: Bool {
        return false
    }
    var isPublic: Bool {
        return true
    }
    var isPushNotificationEnable: Bool {
        return true
    }
    var members: Array<AnyObject> {
        return Array()
    }
    var occupants: Array<AnyObject> {
        return Array()
    }
    var owner: String {
        return ""
    }
    var setting: ZPIMGroupOptions {
        return ZPIMGroupOptions()
    }
}
