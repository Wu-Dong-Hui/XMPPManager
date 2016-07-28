//
//  ZPIMLoactionMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMLoactionMessageBody: ZPIMMessageBody {
    var latitude: Double!
    var longtitude: Double!
    var address: String!
    
    convenience init(latitude: Double, longtitude: Double, address: String) {
        self.init(type: .location)
        self.latitude = latitude
        self.longtitude = longtitude
        self.address = address
    }
}
