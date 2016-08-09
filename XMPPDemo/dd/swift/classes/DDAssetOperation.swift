//
//  DDAssetOperation.swift
//  Dong
//
//  Created by darkdong on 14/11/26.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit
import AssetsLibrary

class DDAssetOperation: NSOperation {
    static var log: DDLog2 = {
        let log = DDLog2()
        log.enabled = false
        return log
        }()
    
    var assetURL: NSURL
    var library: ALAssetsLibrary
    let operationType: String
    var cacheFileURL: NSURL? //cache cropped image or video, but don't apply filter
    var compressionQuality: CGFloat = 0.6
    
    var imageWidthInPixels: CGFloat? //crop
    var lutImage: UIImage? //filter
    var destinationImageFileURL: NSURL?
    var destinationImage: UIImage? //final
    
    var shouldMP4BeSquare = true
    var destinationVideoFileURL: NSURL?
    
    var isOperatingVideo: Bool {
        return operationType == ALAssetTypeVideo
    }
    
    init(assetURL: NSURL, operationType: String, library: ALAssetsLibrary, cacheFileURL: NSURL?) {
        DDAssetOperation.log.log("DDAssetOperation init \(assetURL) operationType \(operationType) cacheFileURL \(cacheFileURL)")
//        NSLog("DDAssetOperation init \(assetURL)")
        self.assetURL = assetURL
        self.library = library
        self.operationType = operationType
        
        super.init()
        
        self.cacheFileURL = cacheFileURL
        destinationVideoFileURL = cacheFileURL
    }
    
    deinit {
//        DDAssetOperation.log.log("DDAssetOperation deinit \(assetURL)")
//        NSLog("DDAssetOperation deinit \(assetURL)")
    }
    
    override func main() {
        DDAssetOperation.log.log("DDAssetOperation begin main? \(NSThread.isMainThread()) \(assetURL) imageWidthInPixels \(imageWidthInPixels) lutImage \(lutImage)")
        if cancelled {
            DDAssetOperation.log.log("DDAssetOperation cancelled at begin \(assetURL)")
            return
        }
        
        let manager = NSFileManager.defaultManager()
        
        repeat {
            //read from cache. if failed, goto read from url
            if let cacheFilePath = cacheFileURL?.path where manager.fileExistsAtPath(cacheFilePath) {
                //read from cache file
                if isOperatingVideo {
                    if let destinationVideoFileURL = destinationVideoFileURL, cacheFileURL = cacheFileURL where destinationVideoFileURL != cacheFileURL {
                        do {
                            //copy cache file to destination file
                            try manager.copyItemAtURL(cacheFileURL, toURL: destinationVideoFileURL)
                        } catch _ {
                        }
                    }
                }else {
                    if let data = NSData(contentsOfURL: cacheFileURL!) {
                        if cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at read cached data \(assetURL)")
                            return
                        }
                        var cachedImage = UIImage(data: data)
                        if cachedImage == nil {
                            //goto read from url
                            break
                        }
                        if cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at create cached image \(assetURL)")
                            return
                        }
                        
                        if let lutImage = lutImage {
                            DDAssetOperation.log.log("DDAssetOperation filter cached image \(assetURL)")
                            cachedImage = cachedImage?.imageByApplyingLutImage(lutImage)
                            if cancelled {
                                DDAssetOperation.log.log("DDAssetOperation cancelled at filter cached image \(assetURL)")
                                return
                            }
                        }
                        //                        DDAssetOperation.log.log("DDAssetOperation got cached image \(asset.assetURL)")
                        if let image = cachedImage, finalFileURL = destinationImageFileURL, finalData = UIImageJPEGRepresentation(image, compressionQuality) {
                            let ok = finalData.writeToURL(finalFileURL, atomically: true)
                            DDAssetOperation.log.log("DDAssetOperation write cached image file to destination ok? \(ok) \(finalFileURL)")
                        }
                        destinationImage = cachedImage
                    }else {
                        //goto read from url
                        break
                    }
                }
            }else {
                //goto read from url
                break
            }
            //read from cache successfully
            return
        }while false
        
        //read from url
        if assetURL.scheme.hasPrefix("http") {
            //download asset from internet
            if let data = NSData(contentsOfURL: assetURL) {
                if cancelled {
                    DDAssetOperation.log.log("DDAssetOperation cancelled at download data \(assetURL)")
                    return
                }
                if let cacheFileURL = cacheFileURL {
                    data.writeToURL(cacheFileURL, atomically: true)
                }
                if isOperatingVideo {
                    if let destinationVideoFileURL = destinationVideoFileURL, cacheFileURL = cacheFileURL where destinationVideoFileURL != cacheFileURL {
                        do {
                            //copy cache file to destination file
                            try manager.copyItemAtURL(cacheFileURL, toURL: destinationVideoFileURL)
                        } catch {
                        }
                    }
                }else {
                    if cancelled {
                        DDAssetOperation.log.log("DDAssetOperation cancelled at write download data to file \(assetURL)")
                        return
                    }
                    var downloadedImage = UIImage(data: data)
                    if cancelled {
                        DDAssetOperation.log.log("DDAssetOperation cancelled at create download image \(assetURL)")
                        return
                    }
                    if let lutImage = lutImage {
                        downloadedImage = downloadedImage?.imageByApplyingLutImage(lutImage)
                        if cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at filter download image \(assetURL)")
                            return
                        }
                    }
                    if let finalFileURL = destinationImageFileURL {
                        data.writeToURL(finalFileURL, atomically: true)
                    }
                    destinationImage = downloadedImage
                }
            }
        }else {
            DDAssetOperation.log.log("DDAssetOperation read from library")
            //read from assets library
            let isOperatingVideo = self.isOperatingVideo
            let shouldMP4BeSquare = self.shouldMP4BeSquare
            let compressionQuality = self.compressionQuality
            let semaphore = dispatch_semaphore_create(0)
            //NOTE: return statement in closure is return from this closure
            library.assetForURL(assetURL, resultBlock: { [weak self] (libAsset) -> Void in
                DDAssetOperation.log.log("DDAssetOperation library begin main? \(NSThread.isMainThread()) \(self?.assetURL) ")
                if let cancelled = self?.cancelled where cancelled {
                    DDAssetOperation.log.log("DDAssetOperation cancelled at library begin \(self?.assetURL)")
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                if isOperatingVideo {
                    DDAssetOperation.log.log("DDAssetOperation read video library")
                    //video file format conversion will fail without correct path extension
                    let tempFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("MOV")
                    libAsset.writeToFile(tempFileURL)
                    if let cacheFileURL = self?.cacheFileURL {
                        DDCamera.convertMOV(tempFileURL, toMP4: cacheFileURL, shouldMP4BeSquare: shouldMP4BeSquare, shouldRemoveMOVFile: true) {
                            if let destinationVideoFileURL = self?.destinationVideoFileURL, cacheFileURL = self?.cacheFileURL where destinationVideoFileURL != cacheFileURL {
                                do {
                                    //copy cache file to destination file
                                    try manager.copyItemAtURL(cacheFileURL, toURL: destinationVideoFileURL)
                                } catch _ {
                                }
                            }
                            dispatch_semaphore_signal(semaphore)
                            return
                        }
                    }else {
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                }else {
                    DDAssetOperation.log.log("DDAssetOperation read image library")
                    var assetImage = libAsset.fullScreenImage
                    if let cancelled = self?.cancelled where cancelled {
                        DDAssetOperation.log.log("DDAssetOperation cancelled at library full screen image \(self?.assetURL)")
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    if let width = self?.imageWidthInPixels {
                        assetImage = assetImage?.imageByPixelWidth(width)
                        DDAssetOperation.log.log("DDAssetOperation crop image size \(assetImage?.size) scale \(assetImage?.scale)")
                    }
                    if let cancelled = self?.cancelled where cancelled {
                        DDAssetOperation.log.log("DDAssetOperation cancelled at library crop image \(self?.assetURL)")
                        dispatch_semaphore_signal(semaphore)
                        return
                    }
                    if let image = assetImage, data = UIImageJPEGRepresentation(image, 1), cacheFileURL = self?.cacheFileURL {
                        if let cancelled = self?.cancelled where cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at library create cropped image data \(self?.assetURL)")
                            dispatch_semaphore_signal(semaphore)
                            return
                        }
                        data.writeToURL(cacheFileURL, atomically: true)
                        if let cancelled = self?.cancelled where cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at library write cropped image to data \(self?.assetURL)")
                            dispatch_semaphore_signal(semaphore)
                            return
                        }
                    }
                    
                    if let lut = self?.lutImage {
                        assetImage = assetImage?.imageByApplyingLutImage(lut)
                        DDAssetOperation.log.log("DDAssetOperation filter image size \(assetImage?.size) scale \(assetImage?.scale)")
                        if let cancelled = self?.cancelled where cancelled {
                            DDAssetOperation.log.log("DDAssetOperation cancelled at library filter image \(self?.assetURL)")
                            dispatch_semaphore_signal(semaphore)
                            return
                        }
                    }
                    
                    if let image = assetImage, finalFileURL = self?.destinationImageFileURL, finalData = UIImageJPEGRepresentation(image, compressionQuality) {
                        finalData.writeToURL(finalFileURL, atomically: true)
                        DDAssetOperation.log.log("DDAssetOperation write fresh image file to destination \(finalFileURL)")
                        //only for test
//                        let finalImage = UIImage(data: finalData)
//                        DDAssetOperation.log.log("DDAssetOperation finalImage size \(finalImage?.size) scale \(finalImage?.scale)")
                    }
                    
                    self?.destinationImage = assetImage
                    dispatch_semaphore_signal(semaphore)
                }
                }) { (error) -> Void in
                    DDAssetOperation.log.log("DDAssetOperation read from library error \(error)")
                    dispatch_semaphore_signal(semaphore)
            }
            DDAssetOperation.log.log("DDAssetOperation wait main? \(NSThread.isMainThread()) \(assetURL)")
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            DDAssetOperation.log.log("DDAssetOperation end main? \(NSThread.isMainThread()) \(assetURL)")
        }
    }
}
