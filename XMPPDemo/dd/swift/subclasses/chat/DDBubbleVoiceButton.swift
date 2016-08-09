//
//  DDBubbleVoiceButton.swift
//  Dong
//
//  Created by darkdong on 15/2/21.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDBubbleVoiceButton: DDButton {
    var contentInset: UIEdgeInsets!
    var contentView: UIImageView!
    // (contentViewWidth - minDurationViewWidth) / (maxDurationViewWidth - minDurationViewWidth) = (duration - minDuration) / (maxDuration - minDuration)
    var contentViewWidth: CGFloat {
        return (self.duration - self.minDuration) / (self.maxDuration - self.minDuration) * (self.maxDurationViewWidth - self.minDurationViewWidth) + self.minDurationViewWidth
    }
    var minDurationViewWidth: CGFloat = 40
    var maxDurationViewWidth: CGFloat = 160
    var minDuration: CGFloat = 1
    var maxDuration: CGFloat = 10
    var duration: CGFloat = 0
    
    private func commonInit() {
        let contentView = UIImageView()
        self.contentView = contentView
        contentView.animationDuration = 1
        self.addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
        
    override func sizeThatFits(size: CGSize) -> CGSize {
        let contentOrigin = CGPoint(x: self.contentInset.left, y: self.contentInset.top)
        let contentSize = CGSize(width: self.contentViewWidth, height: self.height)
        self.contentView.frame = CGRect(origin: contentOrigin, size: contentSize)
        
//        DDLog2.print("DDBubbleVoiceButton contentView \(self.contentView)")

        return CGSize(width: self.contentInset.left + contentSize.width + self.contentInset.right, height: self.contentInset.top + contentSize.height + self.contentInset.bottom)
    }
    
    //MARK: - private
    
    //MARK: - public
    func prepareForReuse() {
    }
}
