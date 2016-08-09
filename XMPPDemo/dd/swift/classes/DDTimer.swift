//
//  DDTimer.swift
//  Dong
//
//  Created by darkdong on 15/1/16.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import Foundation

class DDTimer {
    var timer: NSTimer!
    var handler: ((DDTimer) -> Void)?
    var info: AnyObject?
    
    init(scheduleWithTimeInterval timeInterval: NSTimeInterval, info: AnyObject?, repeats: Bool, handler: ((DDTimer) -> Void)?) {
        self.info = info
        self.handler = handler
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(DDTimer.fire(_:)), userInfo: info, repeats: repeats)
    }
    
    init(timeInterval: NSTimeInterval, info: AnyObject?, repeats: Bool, handler: ((DDTimer) -> Void)?) {
        self.info = info
        self.handler = handler
        timer = NSTimer(timeInterval: timeInterval, target: self, selector: #selector(DDTimer.fire(_:)), userInfo: info, repeats: repeats)
    }
    
    deinit {
        DDLog2.log("DDTimer deinit")
    }
    
    func invalidate() {
        timer.invalidate()
    }
    
    @objc func fire(timer: NSTimer) {
        handler?(self)
    }
}

class DDDisplayLink {
    var displayLink: CADisplayLink!
    var handler: ((DDDisplayLink) -> Void)?
    var info: AnyObject?
    
    init(scheduleWithHandler handler: ((DDDisplayLink) -> Void)?) {
        self.handler = handler
        displayLink = CADisplayLink(target: self, selector: #selector(DDTimer.fire(_:)))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    init(handler: ((DDDisplayLink) -> Void)?) {
        self.handler = handler
        displayLink = CADisplayLink(target: self, selector: #selector(DDTimer.fire(_:)))
    }
    
    deinit {
        DDLog2.log("DDDisplayLink deinit")
    }
    
    func invalidate() {
        displayLink.invalidate()
    }
    
    @objc func fire(timer: CADisplayLink) {
        handler?(self)
    }
}