//
//  ZPIMMediaDownloader.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/11.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit
typealias ZPIMMediaType = ZPIMMessageBodyType

class ZPIMMediaDownloader: NSOperation {
    var mediaType: ZPIMMediaType = .text
    var remoteURL: NSURL!
    var destinationURL: NSURL!
    init(mediaType: ZPIMMediaType, remoteURL: NSURL, destinationURL: NSURL) {
        super.init()
        self.mediaType = mediaType
        self.remoteURL = remoteURL
        self.destinationURL = destinationURL
    }
    override func main() {
        if cancelled {
            DDLogError("operation was cancelled")
            return
        }
        if remoteURL == nil {
            DDLogError("remote url can not be nil")
            return
        }
        if destinationURL == nil {
            DDLogError("download destnation url can not be nil")
            return
        }
        guard let data = NSData(contentsOfURL: remoteURL) else {
            DDLogDebug("error happened")
            return
        }
        switch mediaType {
        case .image:
            let fileName = NSUUID().UUIDString
            let filePath = NSURL(string: destinationURL.absoluteString + "\(fileName).jpg")!
            DDLogDebug(filePath.absoluteString)
            data.writeToURL(filePath, atomically: true)
        default:
            DDLogDebug("unsuppored media type")
            break
        }
    }
    deinit {
        DDLogDebug("deinit")
    }
}
