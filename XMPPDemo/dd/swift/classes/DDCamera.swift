//
//  DDCamera.swift
//  Dong
//
//  Created by darkdong on 15/4/9.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia
import ImageIO
import AssetsLibrary

typealias AssetFilter = (ALAsset) -> Bool

class DDCamera {
    static func deviceAtPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice! {
        for device in AVCaptureDevice.devices() as! [AVCaptureDevice] {
            if position == device.position {
                return device
            }
        }
        return nil
    }
    
    static func setFocusOnDevice(device: AVCaptureDevice, pointOfInterest: CGPoint, focusMode: AVCaptureFocusMode) {
        if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            device.focusPointOfInterest = pointOfInterest
            device.focusMode = focusMode
            device.unlockForConfiguration()
        }
    }
    
    static func setExposureOnDevice(device: AVCaptureDevice, pointOfInterest: CGPoint, exposureMode: AVCaptureExposureMode) {
        if device.focusPointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            device.exposurePointOfInterest = pointOfInterest
            device.exposureMode = exposureMode
            device.unlockForConfiguration()
        }
    }
    
    static func convertPointOfInterestToView(pointOfInterest: CGPoint, videoPreviewLayer: AVCaptureVideoPreviewLayer, cleanApertureRect: CGRect, isMirrored: Bool) -> CGPoint {
        var pointOfView: CGPoint = CGPointZero
        
        let viewSize = videoPreviewLayer.frame.size
        let videoGravity = videoPreviewLayer.videoGravity
        
        if videoGravity == AVLayerVideoGravityResize {
            pointOfView = CGPointMake((1 - pointOfInterest.y) * viewSize.width, pointOfInterest.x * viewSize.height)
        }
        
        var apertureSize = cleanApertureRect.size
        if 0 == apertureSize.height || 0 == apertureSize.width {
            apertureSize = CGSizeMake(2 * viewSize.height, 2 * viewSize.width)
        }
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = viewSize.width / viewSize.height
        
        if videoGravity == AVLayerVideoGravityResizeAspectFill {
            if viewRatio > apertureRatio {
                let y2 = apertureSize.width * (viewSize.width / apertureSize.height)
                pointOfView.x = (1 - pointOfInterest.y) * viewSize.width
                pointOfView.y = pointOfInterest.x * y2 - ((y2 - viewSize.height) / 2)
            } else {
                let x2 = apertureSize.height * (viewSize.height / apertureSize.width)
                pointOfView.x = (1 - pointOfInterest.y) * x2 - (x2 - viewSize.width) / 2
                pointOfView.y = pointOfInterest.x * viewSize.height
            }
        }
        
        if isMirrored {
            pointOfView.x = viewSize.width - pointOfView.x
        }
        return pointOfView
    }
    
    static func convertPointOfViewToInterest(inout pointOfView: CGPoint, videoPreviewLayer: AVCaptureVideoPreviewLayer, cleanApertureRect: CGRect, isMirrored: Bool) -> CGPoint {
        let viewSize = videoPreviewLayer.frame.size
        
        if isMirrored {
            pointOfView.x = viewSize.width - pointOfView.x
        }
        
        let videoGravity = videoPreviewLayer.videoGravity
        
        if videoGravity == AVLayerVideoGravityResize {
            return CGPointMake(pointOfView.y / viewSize.height, 1.0 - (pointOfView.x / viewSize.width))
        }
        
        var apertureSize = cleanApertureRect.size
        if 0 == apertureSize.height || 0 == apertureSize.width {
            apertureSize = CGSizeMake(2 * viewSize.height, 2 * viewSize.width)
        }
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = viewSize.width / viewSize.height
        var xc: CGFloat = 0.5
        var yc: CGFloat = 0.5
        
        if videoGravity == AVLayerVideoGravityResizeAspect {
            if viewRatio > apertureRatio {
                let y2 = viewSize.height
                let x2 = viewSize.height * apertureRatio
                let x1 = viewSize.width
                let blackBar = (x1 - x2) / 2
                // If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                if pointOfView.x >= blackBar && pointOfView.x <= blackBar + x2 {
                    // Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                    xc = pointOfView.y / y2
                    yc = 1 - ((pointOfView.x - blackBar) / x2)
                }
            }else {
                let y2 = viewSize.width / apertureRatio
                let y1 = viewSize.height
                let x2 = viewSize.width
                let blackBar = (y1 - y2) / 2
                // If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                if pointOfView.y >= blackBar && pointOfView.y <= blackBar + y2 {
                    // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                    xc = ((pointOfView.y - blackBar) / y2)
                    yc = 1 - (pointOfView.x / x2)
                }
            }
        }else if videoGravity == AVLayerVideoGravityResizeAspectFill {
            // Scale, switch x and y, and reverse x
            if viewRatio > apertureRatio {
                let y2 = apertureSize.width * (viewSize.width / apertureSize.height)
                xc = (pointOfView.y + ((y2 - viewSize.height) / 2)) / y2 // Account for cropped height
                yc = (viewSize.width - pointOfView.x) / viewSize.width
            } else {
                let x2 = apertureSize.height * (viewSize.height / apertureSize.width)
                yc = 1 - ((pointOfView.x + ((x2 - viewSize.width) / 2)) / x2) // Account for cropped width
                xc = pointOfView.y / viewSize.height
            }
        }
        return CGPointMake(xc, yc)
    }
    
    static func CGImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage! {
        
        let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)
        
        if blockBuffer != nil {
            // Sample buffer is a JPEG compressed image
            var lengthAtOffset = 0
            var length = 0
            var jpgBytes: UnsafeMutablePointer<Int8> = nil
            
            if 0 == CMBlockBufferGetDataPointer(blockBuffer!, 0, &lengthAtOffset, &length, &jpgBytes)
                && lengthAtOffset == length {
                    let jpgData = NSData(bytes: jpgBytes, length: length)
                    let imageSource = CGImageSourceCreateWithData(jpgData, nil)
                    
                    let falseValue = false
                    let decodeOptions: [String: AnyObject] = [
                        String(kCGImageSourceShouldAllowFloat): falseValue,
                        String(kCGImageSourceShouldCache): falseValue
                    ]

                    let cgimage = CGImageSourceCreateImageAtIndex(imageSource!, 0, decodeOptions)
                    return cgimage
            }
        }else {
            // Sample buffer is a BGRA uncompressed image
            let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            
            CVPixelBufferLockBaseAddress(pixelBuffer, 0)
            
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let bitsPerComponent: Int = 8
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.NoneSkipFirst.rawValue)
            let context = CGBitmapContextCreate(baseAddress, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
            let cgimage = CGBitmapContextCreateImage(context)
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
            
            return cgimage
        }
        return nil
    }
    
    static func enumerateAssetsWithGroupType(groupType: ALAssetsGroupType, library: ALAssetsLibrary, filter: AssetFilter? = nil, typeFilter: ALAssetsFilter = ALAssetsFilter.allAssets(), completionHandler: (([ALAsset]!) -> Void)?) {
        var assets: [ALAsset] = []
        library.enumerateGroupsWithTypes(groupType, usingBlock: { (group, pstop) -> Void in
            if let group = group {
                DDLog2.print("enumerate group \(group)")
                group.setAssetsFilter(typeFilter)
                group.enumerateAssetsUsingBlock { (asset, index, pstop) -> Void in
                    if let asset = asset {
                        var shouldAppend = true
                        if let filter = filter {
                            shouldAppend = filter(asset)
                        }
                        if shouldAppend {
                            assets.append(asset)
                        }
                    }
                }
            }else {
                //enumerate group end
                completionHandler?(assets)
            }
            }) { (error) -> Void in
                completionHandler?(nil)
        }
    }
    
    static func enumerateAssetsWithGroup(group: ALAssetsGroup, library: ALAssetsLibrary, filter: AssetFilter? = nil, typeFilter: ALAssetsFilter = ALAssetsFilter.allAssets(), completionHandler: (([ALAsset]!) -> Void)?) {
        var assets: [ALAsset] = []
        group.setAssetsFilter(typeFilter)
        group.enumerateAssetsUsingBlock { (asset, index, pstop) -> Void in
            if let asset = asset {
                var shouldAppend = true
                if let filter = filter {
                    shouldAppend = filter(asset)
                }
                if shouldAppend {
                    assets.append(asset)
                }
            }else {
                //enumerate assets end
                completionHandler?(assets)
            }
        }
    }
    
    static func syncGetAssetsGroupWithType(assetsGroupType: ALAssetsGroupType, library: ALAssetsLibrary) -> ALAssetsGroup? {
        var targetGroup: ALAssetsGroup? = nil
        let semaphore = dispatch_semaphore_create(0)
        dispatch_async(DDSystem.globalBackgroundQueue(), { () -> Void in
            library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, pstop) -> Void in
                if let group = group {
                    if group.type == assetsGroupType {
                        targetGroup = group
                        pstop.memory = true
                    }
                }else {
                    dispatch_semaphore_signal(semaphore)
                }
                }) { (error) -> Void in
                    dispatch_semaphore_signal(semaphore)
            }
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return targetGroup
    }
    
    static func videoOrientationFromAVAssetTrack(videoTrack: AVAssetTrack) -> AVCaptureVideoOrientation {
        let transform = videoTrack.preferredTransform
        //[0, 1, -1, 0, 1080, 0]        Portraint
        //[1, 0, 0, 1, 0, 0]            LandscapeLeft
        //[-1, 0, 0, -1, 1920, 1080]    LandscapeRight
        //[0, -1, 1, 0, 0, 1920]        PortraitUpsideDown
        if transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0 {
            return .Portrait
        }else if transform.a == 1 && transform.b == 0 && transform.c == 0 && transform.d == 1 {
            return .LandscapeLeft
        }else if transform.a == -1 && transform.b == 0 && transform.c == 0 && transform.d == -1 {
            return .LandscapeRight
        }else if transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0 {
            return .PortraitUpsideDown
        }else {
            return .LandscapeLeft
        }
    }
    
    static func convertMOV(movFileURL: NSURL!, toMP4 mp4FileURL: NSURL!, shouldMP4BeSquare: Bool, shouldRemoveMOVFile: Bool, completion: (() -> Void)? = nil) {
        let avAsset = AVAsset(URL: movFileURL)
            var videoComposition: AVMutableVideoComposition! = nil

            if shouldMP4BeSquare {
                let composition = AVMutableComposition()
                composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
                
                let videoTrack = avAsset.tracksWithMediaType(AVMediaTypeVideo)[0] 
                DDLog2.print("videoTrack preferredTransform \(NSStringFromCGAffineTransform(videoTrack.preferredTransform))")
                DDLog2.print("videoTrack naturalSize \(videoTrack.naturalSize)")

                videoComposition = AVMutableVideoComposition()
                //naturalSize is landscape w > h
                let w = videoTrack.naturalSize.width
                let h = videoTrack.naturalSize.height
                let squareLength = min(w, h)
                videoComposition.renderSize = CGSize(width: squareLength, height: squareLength)
                videoComposition.frameDuration = CMTimeMake(1, 30)
                
                //应用preferredTransform，视频已经具有正确的方向和初始位置(0, 0)
                //只需再将视频居中即可
                let videoOrientation = videoOrientationFromAVAssetTrack(videoTrack)
                let tx: CGFloat
                switch videoOrientation {
                case .Portrait, .LandscapeLeft:
                    tx = -(w - h) / 2
                case .LandscapeRight, .PortraitUpsideDown:
                    tx = (w - h) / 2
                }                
                let transform = CGAffineTransformTranslate(videoTrack.preferredTransform, tx, 0)

                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                layerInstruction.setTransform(transform, atTime: kCMTimeZero)
                
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRangeMake(kCMTimeZero, avAsset.duration)
                instruction.layerInstructions = [layerInstruction]
                
                videoComposition.instructions = [instruction]
            }
            
            let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPreset640x480)
            exporter!.videoComposition = videoComposition
            exporter!.outputFileType = AVFileTypeMPEG4
            exporter!.outputURL = mp4FileURL
            do {
                //remove output file if exists
                try NSFileManager.defaultManager().removeItemAtURL(mp4FileURL)
            } catch _ {
            }
            exporter!.exportAsynchronouslyWithCompletionHandler{ () -> Void in
                if shouldRemoveMOVFile {
                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(movFileURL)
                    } catch _ {
                    }
                }
                completion?()
            }
    }
}