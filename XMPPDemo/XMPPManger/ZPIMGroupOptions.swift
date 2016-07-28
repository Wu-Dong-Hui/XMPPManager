//
//  ZPIMGroupOptions.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

@objc enum ZPIMGroupStyle: Int {
    case onlyOwnerInvite
    case memberCanInvite
    case needApproval
    case openJoin
}
class ZPIMGroupOptions: NSObject {
    var style: ZPIMGroupStyle = .openJoin
    var maxUseCount: Int = 200
}
