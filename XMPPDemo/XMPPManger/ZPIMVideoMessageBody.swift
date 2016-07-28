//
//  ZPIMVideoMessageBody.swift
//  XMPPDemo
//
//  Created by Roy on 16/7/27.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ZPIMVideoMessageBody: ZPIMFileMessageBody {
    var duration: Int!
    var thumbnailLocalPath: String!
    var thumbnailRemotePath: String!
    var thumbnailSecretKey: String!
    var thumbnailSize: CGSize!
    var thumbnailDownloadStatus: ZPIMDownloadStatus = .pending
}
