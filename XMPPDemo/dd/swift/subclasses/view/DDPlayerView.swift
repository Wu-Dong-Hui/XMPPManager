//
//  DDPlayerView.swift
//  Dong
//
//  Created by darkdong on 15/6/27.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit
import AVFoundation

class DDPlayerView: UIView {
    var avPlayer: AVPlayer! {
        get {
            return (layer as! AVPlayerLayer).player
        }
        set {
            (layer as! AVPlayerLayer).player = newValue
        }
    }
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        (layer as! AVPlayerLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
