//
//  DDStarRateView.swift
//  Dong
//
//  Created by darkdong on 15/3/13.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDStarRateView: UIView {
    var rate: Float = 0 {
        didSet {
            drawStars()
        }
    }
    var maxNumberOfStars = 5
    var allowHalfStar = true
    var editable = true
    var imageForFullStar: UIImage!
    var imageForHalfStar: UIImage!
    var imageForEmptyStar: UIImage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let starWidth = frame.size.width / CGFloat(maxNumberOfStars)
        for starNumber in 1...maxNumberOfStars {
            let star = DDButton(frame: CGRect(x: 0, y: 0, width: starWidth, height: frame.size.height))
            star.tag = starNumber
            star.touchUpInsideHandler = { [weak self] button in
                self?.setRateWithStarNumber(starNumber)
            }
            addSubview(star)
        }
        layoutSubviewsHorizontally()
        setDefaults()
        drawStars()
    }
    
    func setRateWithStarNumber(starNumber: Int) {
        if !editable {
            return
        }
        if self.rate != Float(starNumber) {
            self.rate = Float(starNumber)
        }else {
            if self.allowHalfStar {
                self.rate -= 0.5
            }
        }
    }
    
    func drawStars() {
        for starNumber in 1...maxNumberOfStars {
            let star = self.viewWithTag(starNumber) as! DDButton
            if Float(starNumber) <= self.rate {
                star.setImage(imageForFullStar, forState: .Normal)
            }else {
                if self.allowHalfStar && Float(starNumber) == self.rate + 0.5 {
                    star.setImage(imageForHalfStar, forState: .Normal)
                }else {
                    star.setImage(imageForEmptyStar, forState: .Normal)
                }
            }
        }
    }
    
    func setDefaults() {
        imageForFullStar = UIImage(namedNoCache: "DDMisc.bundle/star_full")
        imageForHalfStar = UIImage(namedNoCache: "DDMisc.bundle/star_half")
        imageForEmptyStar = UIImage(namedNoCache: "DDMisc.bundle/star_empty")
    }
}