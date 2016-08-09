//
//  DDPlayer.swift
//  Dong
//
//  Created by darkdong on 15/6/7.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation
import AVFoundation

class DDPlayer {
    static let sharedPlayer = DDPlayer()
    
    let avPlayer: AVPlayer
    var itemURL: NSURL?
    var shouldLoopPlay: Bool = false
    var isPlaying: Bool {
        return avPlayer.rate == 1
    }
    var playEndObserver: NSObjectProtocol?
    var playEndHandler: (() -> Void)?
    var object: AnyObject?
    
    init() {
        avPlayer = AVPlayer()
        
        playEndObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            
            if let playingItem = self?.avPlayer.currentItem, let item = notification.object as? AVPlayerItem where playingItem === item {
                item.seekToTime(kCMTimeZero)
                if let shouldLoopPlay = self?.shouldLoopPlay where shouldLoopPlay {
                    DDSystem.delay(0.5, closure: { () -> () in
                        self?.play(fromStart: true)
                    })
                }else {
                    self?.playEndHandler?()
                }
            }
        }
    }
    
    deinit {
        if let observer = playEndObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func play(fromStart fromStart: Bool) {
        guard let itemURL = itemURL else {
            return
        }
        //compare currentItem with item in player
        var replacementItem: AVPlayerItem? = nil
        if let item = avPlayer.currentItem {
            //player has current item
            if let asset = item.asset as? AVURLAsset where asset.URL != itemURL {
                //player's current item is NOT the same with currentItemURL, use new item instead
                replacementItem = AVPlayerItem(URL: itemURL)
            }
        }else {
            //player has no current item, create one to play
            replacementItem = AVPlayerItem(URL: itemURL)
        }
        
        if replacementItem != nil {
            avPlayer.replaceCurrentItemWithPlayerItem(replacementItem)
            avPlayer.rate = 0
        }
    
        if avPlayer.rate == 0 {
            if fromStart {
                avPlayer.seekToTime(kCMTimeZero)
            }
            avPlayer.play()
        }else {
            avPlayer.pause()
        }
    }

    func pause() {
        avPlayer.pause()
    }
    
    func reset() {
        itemURL = nil
        avPlayer.replaceCurrentItemWithPlayerItem(nil)
        avPlayer.rate = 0
    }
}