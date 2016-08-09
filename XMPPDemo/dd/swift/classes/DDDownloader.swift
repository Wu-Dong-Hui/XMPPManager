//
//  DDDownloader.swift
//  Dong
//
//  Created by darkdong on 14/10/24.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation

class DDDownloader {
//    static let sharedDownloader = DDDownloader(destinationDirectoryURL: "download")
    
    let destinationDirectoryURL: NSURL
    let resumeDirectoryURL: NSURL?

//    var downloadRequest: Request!
    
    init(destinationDirectoryURL: NSURL, resumeDirectoryURL: NSURL?) {
        NSLog("DDDownloader destinationDirectoryURL \(destinationDirectoryURL) resumeDirectoryURL \(resumeDirectoryURL)")
        let manager = NSFileManager.defaultManager()
        self.destinationDirectoryURL = destinationDirectoryURL
        do {
            try manager.createDirectoryAtURL(destinationDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }

        if let url = resumeDirectoryURL {
            do {
                try manager.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        self.resumeDirectoryURL = resumeDirectoryURL
    }
    // Alamofire need iOS 8+
//    func downloadURL(url: NSURL!, byResumeFileURL resumeFileURL: NSURL, toDestinationFileURL destFileURL: NSURL, completion: ((NSURL!) -> Void)?) {
//        DDLog2.print("DDDownloader downloadURL \(url) byResumeFileURL \(resumeFileURL) toDestinationFileURL \(destFileURL)")
//        if let filePath = destFileURL.path where NSFileManager.defaultManager().fileExistsAtPath(filePath) {
//            DDLog2.print("DDDownloader destination file already exists")
//            completion?(destFileURL)
//        }else {
//            let downloadRequest: Request
//            if let resumeData = NSData(contentsOfURL: resumeFileURL) {
//                DDLog2.print("DDDownloader resume")
//                downloadRequest = download(resumeData: resumeData) { (destinationFileURL, response) -> (NSURL) in
//                    return destFileURL
//                }
//            }else {
//                DDLog2.print("DDDownloader new download")
//                downloadRequest = download(.GET, url) { (destinationFileURL, response) -> (NSURL) in
//                    return destFileURL
//                }
//            }
//            downloadRequest.progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
//                DDLog2.print("DDDownloader bytesWritten \(bytesWritten) totalBytesWritten \(totalBytesWritten) totalBytesExpectedToWrite \(totalBytesExpectedToWrite)")
//            }).response(completionHandler: { (request, response, data, error) -> Void in
//                if error == nil {
//                    completion?(destFileURL)
//                }else {
//                    if let resumeData = data {
//                        resumeData.writeToURL(resumeFileURL, atomically: true)
//                    }
//                    completion?(nil)
//                }
//            })
//        }
//    }
}