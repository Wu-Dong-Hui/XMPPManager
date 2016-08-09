//
//  ALAssetExtension.swift
//  Dong
//
//  Created by darkdong on 14-10-15.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import CoreLocation
import ImageIO

extension ALAsset {
    static func readImageWithAssetURL2(assetURL: NSURL, queue: NSOperationQueue, library: ALAssetsLibrary, cacheFileURL: NSURL?, imageWidthInPixels: CGFloat?, lutImage: UIImage?, completion: ((NSURL, UIImage?) -> Void)?) {
        let operation = DDAssetOperation(assetURL: assetURL, operationType: ALAssetTypePhoto, library: library, cacheFileURL: cacheFileURL)
        operation.imageWidthInPixels = imageWidthInPixels
        operation.lutImage = lutImage
        operation.completionBlock = { [weak operation] in
            let image = operation?.destinationImage
            completion?(assetURL, image)
        }
        queue.addOperation(operation)
    }
    static func readImageWithAssetURL(assetURL: NSURL, queue: NSOperationQueue, library: ALAssetsLibrary, cacheFileURL: NSURL?, imageWidthInPixels: CGFloat?, lutImage: UIImage?, completion: ((NSURL, UIImage?) -> Void)?) {
        let operation = DDAssetOperation(assetURL: assetURL, operationType: ALAssetTypePhoto, library: library, cacheFileURL: cacheFileURL)
        operation.imageWidthInPixels = imageWidthInPixels
        operation.lutImage = lutImage
        operation.completionBlock = { [weak operation] in
            let image = operation?.destinationImage
            dispatch_async(dispatch_get_main_queue()) {
                completion?(assetURL, image)
            }
        }
        queue.addOperation(operation)
    }
    
    static func readVideoWithAssetURL(assetURL: NSURL, queue: NSOperationQueue, library: ALAssetsLibrary, cacheFileURL: NSURL?, completion: ((NSURL?, NSURL?) -> Void)?) {
        let operation = DDAssetOperation(assetURL: assetURL, operationType: ALAssetTypeVideo, library: library, cacheFileURL: cacheFileURL)
        operation.completionBlock = { [weak operation] in
            let videoFileURL = operation?.destinationVideoFileURL
            dispatch_async(dispatch_get_main_queue()) {
                completion?(assetURL, videoFileURL)
            }
        }
        queue.addOperation(operation)
    }
    
    var type: String? {
        return self.valueForProperty(ALAssetPropertyType) as? String
    }
    var isVideo: Bool {
        if let type = self.type where type == ALAssetTypeVideo {
            return true
        }else {
            return false
        }
    }
    var location: CLLocation? {
        return self.valueForProperty(ALAssetPropertyLocation) as? CLLocation
    }
    var duration: Float? {
        return self.valueForProperty(ALAssetPropertyDuration) as? Float
    }
    var date: NSDate? {
        return self.valueForProperty(ALAssetPropertyDate) as? NSDate
    }
    var orientation: ALAssetOrientation? {
        if let orientationInt = self.valueForProperty(ALAssetPropertyOrientation) as? Int {
            return ALAssetOrientation(rawValue: orientationInt)
        }else {
            return nil
        }
    }
    var assetURL: NSURL? {
        return self.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
    }
    
    var tiffInfo: [String: AnyObject]? {
        if let metadata = self.defaultRepresentation().metadata() {
            let tiffDic = metadata[kCGImagePropertyTIFFDictionary] as? NSDictionary
            return tiffDic as? [String: AnyObject]
        }else {
            return nil
        }
    }
    
    var exifInfo: [String: AnyObject]? {
        if let metadata = self.defaultRepresentation().metadata() {
            let exifDic = metadata[kCGImagePropertyExifDictionary] as? NSDictionary
            return exifDic as? [String: AnyObject]
        }else {
            return nil
        }
    }
    
    var fullResolutionImage: UIImage? {
        if let representation = self.defaultRepresentation() {
            let rawOrientation = self.orientation?.rawValue ?? 0
            let imageOrientation = UIImageOrientation(rawValue: rawOrientation) ?? .Up
            let scale = CGFloat(representation.scale())
            let cgimage = representation.fullResolutionImage().takeUnretainedValue()
            return UIImage(CGImage: cgimage, scale: scale, orientation: imageOrientation)
        }else {
            return nil
        }
    }
    
    var fullScreenImage: UIImage? {
        if let representation = self.defaultRepresentation(), cgimage = representation.fullScreenImage()?.takeUnretainedValue() {
            return UIImage(CGImage: cgimage)
        }else {
            return nil
        }
    }
    
    var thumbnailImage: UIImage? {
        if let cgimage = self.thumbnail()?.takeUnretainedValue() {
            return UIImage(CGImage: cgimage)
        }else {
            return nil
        }
    }
    
    func isFromCamera() -> Bool {
        
        if let pathExtension = NSURL(fileURLWithPath:defaultRepresentation().filename()).pathExtension where pathExtension == "PNG" {
            return false
        }
//        if location == nil {
//            return false
//        }
        return true
    }
    
    //NOTE: defaultRepresentation().filename() may conflict, use assetURL instead
    func uniqueFilenameForType(type: String) -> String? {
//        let filename = defaultRepresentation().filename()
        let pathExtension = NSURL(fileURLWithPath:defaultRepresentation().filename()).pathExtension!
        let baseFilename = assetURL!.stringWithMD5!
        if isVideo {
            //asset is video
            if type == ALAssetTypePhoto {
                //video's cover
                return NSURL(fileURLWithPath: baseFilename).URLByAppendingPathExtension("JPG").path
            }else {
                //itself
                return NSURL(fileURLWithPath: baseFilename).URLByAppendingPathExtension(pathExtension).path
            }
        }else {
            //asset is image
            if type == ALAssetTypePhoto {
                //itself
                return NSURL(fileURLWithPath: baseFilename).URLByAppendingPathExtension(pathExtension).path
            }else {
                //no video in image
                return nil
            }
        }
    }
    
    func writeToFile(fileURL: NSURL) -> Bool {
        if let filePath = fileURL.filePathURL?.path where NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil), let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            let bufferSize = 1024 * 1024
            let rep = self.defaultRepresentation()
            let buffer = UnsafeMutablePointer<UInt8>.alloc(bufferSize)
            var offset: Int64 = 0
            var bytesRead = 0
            
            repeat {
                autoreleasepool {
                    bytesRead = rep.getBytes(buffer, fromOffset: offset, length: bufferSize, error: nil)
                    let data = NSData(bytesNoCopy: buffer, length: bytesRead, freeWhenDone: false)
                    fileHandle.writeData(data)
                    offset += bytesRead
                }
            }while bytesRead > 0
            
            buffer.destroy()
            NSLog("write \(self) (\(rep.size()) Bytes) to \(filePath)")
            return true
        }
        return false
    }
    
    //only for debug
//    public override var description: String {
////        if let desc = date?.descriptionWithLocale(NSLocale.currentLocale()) {
//        if let desc = date?.description {
//            return desc
//        }
//        return "*********** NO DATE ************"
//    }
}