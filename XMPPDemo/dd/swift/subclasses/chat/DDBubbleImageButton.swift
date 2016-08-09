//
//  DDBubbleImageButton.swift
//  Dong
//
//  Created by darkdong on 15/3/24.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDBubbleImageButton: DDButton {
    static var constraintSize = CGSize(width: 100, height: 100)
    var maskImage: UIImage!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        if let image = self.imageForState(.Normal) {
            return image.size.scaleToFillSize(DDBubbleImageButton.constraintSize)
        }else {
            return size
        }
    }
    
    //MARK: - private
    
    //MARK: - public
    func prepareForReuse() {
        self.layer.mask = nil
        self.setBackgroundImage(nil, forState: .Normal)
        self.setBackgroundImage(nil, forState: .Highlighted)
        self.setImage(nil, forState: .Highlighted)
    }
    
    func clipsToBubble() {
        let maskView = UIImageView(frame: self.bounds)
        maskView.image = self.maskImage
        self.layer.mask = maskView.layer
    }
}
