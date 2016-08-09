//
//  DDBadgeView.swift
//  Dong
//
//  Created by darkdong on 15/4/1.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDBadgeView: UIView {
    var imageView: UIImageView!
    var label: UILabel!
    var minLabelWidth: CGFloat = 8
    var badgeText: String! {
        get {
            return self.label.text
        }
        set {
            self.label.text = newValue
            self.label.sizeToFit()
            
            let delta = self.label.width - self.minLabelWidth
            if delta > 0 {
                self.width += delta
            }
            self.label.center = self.imageView.center
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)

        let image = UIImage(namedNoCache: "DDMisc.bundle/badge")?.resizableImage()
        let imageView = UIImageView(image: image)
        self.imageView = imageView
        imageView.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(imageView)
        
        let label = UILabel(frame: imageView.frame)
        self.label = label
        label.font = UIFont.boldSystemFontOfSize(15)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        self.addSubview(label)
    }
}
