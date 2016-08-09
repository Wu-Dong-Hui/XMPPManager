//
//  UIImageViewExtension.swift
//  Dong
//
//  Created by darkdong on 14/12/1.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(newImage: UIImage!, animated: Bool, duration: NSTimeInterval = 0.3) {
        if (!animated) {
            self.image = newImage
            return
        }
        // Create a transparent imageView which will display the transition image.
        let oldImageView = UIImageView(frame: self.bounds)
        oldImageView.contentMode = self.contentMode
        oldImageView.clipsToBounds = self.clipsToBounds
        oldImageView.image = self.image
        
        let newImageView = UIImageView(frame: self.bounds)
        newImageView.contentMode = self.contentMode
        newImageView.clipsToBounds = self.clipsToBounds
        newImageView.image = newImage
        newImageView.alpha = 0
        
        self.image = nil
        self.insertSubview(oldImageView, atIndex: 0)
        self.insertSubview(newImageView, aboveSubview: oldImageView)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            newImageView.alpha = 1
            }) { (finished) -> Void in
                if finished {
                    self.image = newImage
                    oldImageView.removeFromSuperview()
                    newImageView.removeFromSuperview()
                }
        }
    }
    
    @available(iOS 8.0, *)
    func addBlurEffectStyle(style: UIBlurEffectStyle) {
        let blurEffect = UIBlurEffect(style: style)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.bounds
        self.addSubview(visualEffectView)
    }
}