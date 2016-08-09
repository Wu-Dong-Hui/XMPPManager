//
//  DDPartImageView.swift
//  Dong
//
//  Created by darkdong on 15/9/8.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDPartImageView: UIView {
    var image: UIImage? {
        didSet {
            draw()
        }
    }
    //imageOffset(x, y): 0 means min, 0.5 means center, 1 means max
    var imageOffset = CGPointZero {
        didSet {
            draw()
        }
    }
    
    //imageRect's coordinate is in self
    var imageRect: CGRect {
        if let image = image {
            //get image size that fill frame size and keep aspect ratio
            let imageSize = image.size.scaleToFillSize(frame.size)
            
//            DDLog2.print("frame \(frame) imageSize \(imageSize)")

            //calculate image rect with offset
            let x = DDMath.similarY(x1: 0, x: imageOffset.x, x2: 1, y1: 0, y2: imageSize.width - frame.width)
            let y = DDMath.similarY(x1: 0, x: imageOffset.y, x2: 1, y1: 0, y2: imageSize.height - frame.height)
            
//            DDLog2.print("imageOffset \(imageOffset) x \(x) y \(y)")
            
            //translate x y to center rect
            return CGRect(origin: CGPoint(x: -x, y: -y), size: imageSize)
        }else {
            return frame
        }
    }
    
    //imageFrame's coordinate is in super
    var imageFrame: CGRect {
        return imageRect.offsetBy(dx: frame.minX, dy: frame.minY)
    }
    
    private var drawingRect: CGRect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //get rid of dark line and black background sometimes
        opaque = false
//        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        image = decoder.decodeObjectForKey("image") as? UIImage
        imageOffset = decoder.decodeCGPointForKey("imageOffset")
    }
    
    override func encodeWithCoder(encoder: NSCoder) {
        super.encodeWithCoder(encoder)
        
        encoder.encodeObject(image, forKey: "image")
        encoder.encodeCGPoint(imageOffset, forKey: "imageOffset")        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        if let image = image, drawingRect = drawingRect {
//            DDLog2.print("drawRect drawingRect \(drawingRect) image \(image)")
            image.drawInRect(drawingRect)
        }
    }
    
    func draw() {
        drawingRect = imageRect
        setNeedsDisplay()
    }
}
