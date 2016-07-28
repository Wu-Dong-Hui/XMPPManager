//
//  ZPIMFileMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
enum ZPIMDownloadStatus {
    case downloading
    case successed
    case failed
    case pending
}
class ZPIMFileMessageBody: ZPIMMessageBody {
    var displayName: String!
    var localPath: String!
    var reomotePath: String!
    var secretKey: String!
    var fileLength: Int64!
    var downloadStatus: ZPIMDownloadStatus = .pending
    
    convenience init(localPath: String, displayName: String) {
        self.init(type: .file)
        self.displayName = displayName
    }
    convenience init(data: NSData, displayName: String) {
        self.init(type: .file)
        self.displayName = displayName
    }
    override init(type: ZPIMMessageBodyType) {
        super.init(type: .file)
    }
}
