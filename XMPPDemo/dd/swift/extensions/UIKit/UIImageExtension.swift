//
//  UIImageExtension.swift
//  Dong
//
//  Created by darkdong on 14-8-5.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit
import ImageIO
import CoreImage

extension UIImage {
    private struct Static {
        static let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        static let imageExtNames = ["png", "jpg"]
    }
    
    static func imageFromView(view: UIView) -> UIImage! {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    convenience init?(namedNoCache: String!) {
        let baseNames: [String]
        if UIScreen.mainScreen().scale == 3 {
            baseNames = [namedNoCache + "@3x", namedNoCache + "@2x", namedNoCache]
        }else {
            baseNames = [namedNoCache + "@2x", namedNoCache + "@3x", namedNoCache]
        }
        let bundle = NSBundle.mainBundle()
        var filePath = ""
        
        findImageFile: for extName in Static.imageExtNames {
            for baseName in baseNames {
                if let path = bundle.pathForResource(baseName, ofType: extName) {
                    filePath = path
                    break findImageFile
                }
            }
        }
        self.init(contentsOfFile: filePath)
    }
    
    convenience init?(rawData: NSData!, width: Int, height: Int) {
        let numberOfComponents = 4
        let bitsPerComponent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue)
        let shouldInterpolateAndSmooth = true
        
        let dataProviderRef = CGDataProviderCreateWithData(nil, rawData.bytes, width * height * numberOfComponents, nil)
        let cgImageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerComponent * numberOfComponents, width * numberOfComponents, Static.colorSpace, bitmapInfo, dataProviderRef, nil, shouldInterpolateAndSmooth, CGColorRenderingIntent.RenderingIntentDefault)
        self.init(CGImage: cgImageRef!, scale: 1, orientation: .Up)
    }
    
    convenience init!(color: UIColor!, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: CGPointZero, size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
    
    func tintedImage(color: UIColor = UIColor(white: 0, alpha: 0.3)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(origin: CGPointZero, size: self.size)
        self.drawInRect(rect)
        color.set()
        UIRectFillUsingBlendMode(rect, CGBlendMode.SourceAtop)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    func resizableImage(insets: UIEdgeInsets? = nil) -> UIImage! {
        if let insets = insets {
            return self.resizableImageWithCapInsets(insets)
        }else {
            let width = self.size.width
            let height = self.size.height
            return self.resizableImageWithCapInsets(UIEdgeInsets(top: height / 2, left: width / 2, bottom: height / 2, right: width / 2))
        }
    }
    
    func flippedImage() -> UIImage? {
        let orientation: UIImageOrientation
        switch self.imageOrientation {
        case .Down:
            orientation = .DownMirrored
        default:
            orientation = .UpMirrored
        }
        if let cgImage = CGImage {
            return UIImage(CGImage: cgImage, scale: self.scale, orientation: orientation)
        }else {
            return nil
        }
    }
    
    func imageByPNGRepresentation() -> UIImage! {
        let imageData = UIImagePNGRepresentation(UIImage(CGImage: self.CGImage!))
        return UIImage(data: imageData!)
    }
    
    func imageByCroppingRect(rect: CGRect) -> UIImage! {
        let transform = CGAffineTransformMakeScale(self.scale, self.scale)
        let transformedRect = CGRectApplyAffineTransform(rect, transform)
        let cgimage = CGImageCreateWithImageInRect(self.CGImage, transformedRect)
        return UIImage(CGImage: cgimage!, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func imageByScaling(scale: CGFloat) -> UIImage! {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        return self.imageByResizing(size)
    }
    
    func imageByBlendingImage(image: UIImage!, mode: CGBlendMode, alpha: CGFloat) -> UIImage! {
        let selfImagePixelSize = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(self.scale, self.scale))
        let selfImagePixelRect = CGRect(origin: CGPointZero, size: selfImagePixelSize)
        
        let blendingImagePixelSize = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(image.scale, image.scale))
        let blendingImagePixelRect = CGRect(origin: CGPointZero, size: blendingImagePixelSize)
        
        let deltaX = selfImagePixelRect.midX - blendingImagePixelRect.midX
        let deltaY = selfImagePixelRect.midY - blendingImagePixelRect.midY
        
        //center centeredBlendingRect
        let centeredBlendingRect = CGRectOffset(blendingImagePixelRect, deltaX, deltaY)
        
        UIGraphicsBeginImageContextWithOptions(selfImagePixelSize, false, 1)
        
        self.drawInRect(selfImagePixelRect)
        image.drawInRect(centeredBlendingRect, blendMode: mode, alpha: alpha)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return blendedImage
    }
    
    func imageByRoundingCornerRadius(cornerRadius: CGFloat) -> UIImage! {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let rect = CGRect(origin: CGPointZero, size: self.size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addClip()
        self.drawInRect(rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    func imageByResizing(size: CGSize, quality: CGInterpolationQuality = CGInterpolationQuality.Default) -> UIImage! {
        var drawTransposed = false
        switch self.imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            break
        }
        let transform = self.transformForSize(size)
        return self.resizedImage(size: size, transform: transform, drawTransposed: drawTransposed, quality: quality)
    }
    
    func imageByPixelSize(pixelSize: CGSize?, quality: CGInterpolationQuality = CGInterpolationQuality.Default) -> UIImage! {
        if let pixelSize = pixelSize {
            var drawTransposed = false
            switch self.imageOrientation {
            case .Left, .LeftMirrored, .Right, .RightMirrored:
                drawTransposed = true
            default:
                break
            }
            let size = CGSizeApplyAffineTransform(pixelSize, CGAffineTransformMakeScale(1.0 / self.scale, 1.0 / self.scale))
            let transform = self.transformForSize(size)
            return self.resizedImage(size: size, transform: transform, drawTransposed: drawTransposed, quality: quality)
        }else {
            return self
        }
    }
    
    func imageByPixelWidth(pixelWidth: CGFloat?, quality: CGInterpolationQuality = CGInterpolationQuality.Default) -> UIImage! {
        if let pixelWidth = pixelWidth {
            let scale = pixelWidth / (self.size.width * self.scale)
            let pixelHeight = scale * self.size.height * self.scale
            let pixelSize = CGSize(width: pixelWidth, height: pixelHeight)
            return self.imageByPixelSize(pixelSize, quality: quality)
        }else {
            return self
        }
    }
    
    func imageByPixelHeight(pixelHeight: CGFloat?, quality: CGInterpolationQuality = CGInterpolationQuality.Default) -> UIImage! {
        if let pixelHeight = pixelHeight {
            let scale = pixelHeight / (self.size.height * self.scale)
            let pixelWidth = scale * self.size.width * self.scale
            let pixelSize = CGSize(width: pixelWidth, height: pixelHeight)
            return self.imageByPixelSize(pixelSize, quality: quality)
        }else {
            return self
        }
    }
    
    //too slow to use
    func imageByApplyingBlur(radius radius: CGFloat) -> UIImage? {
        let filter = CIFilter(name: "CIGaussianBlur")
        filter!.setDefaults()
        let inputCIImage = ObjcBridge.CIImageFromCGImage(self.CGImage)
        DDLog2.print("inputCIImage \(inputCIImage)")
        filter!.setValue(inputCIImage, forKey: kCIInputImageKey)
        filter!.setValue(radius, forKey: kCIInputRadiusKey)
        
        let outputCIImage = filter!.outputImage
        DDLog2.print("outputCIImage \(outputCIImage)")
        //        return UIImage(CIImage: outputCIImage)
        let context = CIContext(options:nil)
        let cgImage = context.createCGImage(outputCIImage!, fromRect:inputCIImage.extent)
        let image = UIImage(CGImage: cgImage)
        DDLog2.print("image \(image)")
        return image
    }
    
    class func addOrientationToImageMetaData(inout imageMetaData: [NSObject: AnyObject], deviceOrientation: UIDeviceOrientation) {
        //     UIDeviceOrientation                  CGImagePropertyOrientation (Location of the origin of the image)
        //     Unknown
        //     Portrait                             1 (Top, left)
        //     PortraitUpsideDown                   3 (Bottom, right)
        //     LandscapeLeft(button at right side)  8 (Left, bottom)
        //     LandscapeRight(button at left side)  6 (Right, top)
        //     FaceUp
        //     FaceDown
        
        var cgImagePropertyOrientation = 1
        switch deviceOrientation {
        case .PortraitUpsideDown:
            cgImagePropertyOrientation = 3
        case .LandscapeLeft:
            cgImagePropertyOrientation = 8
        case .LandscapeRight:
            cgImagePropertyOrientation = 6
        default:
            break
        }
        imageMetaData[String(kCGImagePropertyOrientation)] = cgImagePropertyOrientation
    }
    
    func print(prefix: String = "UIImage:") {
        var orientation = "Unknown"
        switch self.imageOrientation {
        case .Up:
            orientation = "Up"
        case .Down:
            orientation = "Down"
        case .Left:
            orientation = "Left"
        case .Right:
            orientation = "Right"
        case .UpMirrored:
            orientation = "UpMirrored"
        case .DownMirrored:
            orientation = "DownMirrored"
        case .LeftMirrored:
            orientation = "LeftMirrored"
        case .RightMirrored:
            orientation = "RightMirrored"
        }
        NSLog("\(prefix) size: \(self.size) orientation: \(orientation) scale: \(self.scale)")
    }
    
    private // MARK:- private
    
    func transformForSize(size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch self.imageOrientation {
        case .Down, // EXIF = 3
        .DownMirrored: // EXIF = 4
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .Left, // EXIF = 6
        .LeftMirrored: // EXIF = 5
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case .Right, // EXIF = 8
        .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
        default:
            break
        }
        
        switch self.imageOrientation {
        case .UpMirrored, // EXIF = 2
        .DownMirrored: // EXIF = 4
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        case .LeftMirrored, // EXIF = 5
        .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
        default:
            break
        }
        
        return transform
    }
    
    func resizedImage(size size: CGSize, transform: CGAffineTransform, drawTransposed: Bool, quality: CGInterpolationQuality = CGInterpolationQuality.Default) -> UIImage! {
        let rect = CGRectIntegral(CGRectMake(0, 0, size.width * self.scale, size.height * self.scale))
        let transposedRect = CGRect(x: 0, y: 0, width: rect.height, height: rect.width)
        let cgimage = self.CGImage
        
        //        let bitmapInfo = CGImageGetBitmapInfo(cgimage)
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitmap: CGContext = CGBitmapContextCreate(nil, Int(rect.width), Int(rect.height), 8, Int(rect.width) * 4, Static.colorSpace, bitmapInfo.rawValue)!
        
        CGContextConcatCTM(bitmap, transform)
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)
        
        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, drawTransposed ? transposedRect : rect, cgimage)
        
        // Get the resized image from the context and a UIImage
        let resizedCGImage = CGBitmapContextCreateImage(bitmap)
        
        return UIImage(CGImage: resizedCGImage!, scale: self.scale, orientation: .Up)
    }
}
