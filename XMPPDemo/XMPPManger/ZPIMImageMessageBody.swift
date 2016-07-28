//
//  ZPIMImageMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMImageMessageBody: ZPIMFileMessageBody {
    var size: CGSize!
    var compressRatio: CGFloat!
    var thumbnailDisplayName: String!
    var thunbnailLocalPath: String!
    var thumbnailRemotePath: String!
    var thumbnailSecretKey: String!
    var thumbnailFileLength: Int64!
    var thumbnailDownloadStatus: ZPIMDownloadStatus = .pending
    
    convenience init(data: NSData, thumbnailData: NSData) {
        self.init(type: .image)
    }
    
}
