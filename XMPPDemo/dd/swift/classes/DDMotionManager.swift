//
//  DDMotionManager.swift
//  Dong
//
//  Created by darkdong on 14-8-15.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit
import CoreMotion

typealias DDMotionManagerAccelerometerHandler = (UIDeviceOrientation, CGAffineTransform) -> Void

class DDMotionManager {
    var deviceOrientation = UIDeviceOrientation.Portrait
    var transform = CGAffineTransformIdentity
    let motionManager = CMMotionManager()
    
    var accelerometerHandlers: [String: DDMotionManagerAccelerometerHandler] = [:]
    
    static let sharedManager = DDMotionManager()
    
    func startAccelerometerUpdates(updateInterval: NSTimeInterval) {
        self.motionManager.accelerometerUpdateInterval = updateInterval
        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) { (accelerometerData, error) -> Void in
//            NSLog("AccelerometerUpdates isMainThread: \(NSThread.isMainThread())")
            
            let acceleration = accelerometerData!.acceleration
            
            let absX = abs(acceleration.x)
            let absY = abs(acceleration.y)
            let absZ = abs(acceleration.z)
            let maxValue = max(absX, absY, absZ)
            
            var deviceOrientation = self.deviceOrientation
            
            if maxValue == absY {
                //portrait
                if (acceleration.y > 0) {
                    if deviceOrientation != .PortraitUpsideDown {
                        deviceOrientation = .PortraitUpsideDown
                    }
                }else {
                    if deviceOrientation != .Portrait {
                        deviceOrientation = .Portrait
                    }
                }
            }else if (maxValue == absX) {
                //landscape
                if (acceleration.x > 0) {
                    if deviceOrientation != .LandscapeRight {
                        deviceOrientation = .LandscapeRight
                    }
                }else {
                    if deviceOrientation != .LandscapeLeft {
                        deviceOrientation = .LandscapeLeft
                    }
                }
            }else {
                //keep device orientation
            }
            
            if deviceOrientation != self.deviceOrientation {
                self.deviceOrientation = deviceOrientation
                
                var radian = 0.0
                if .LandscapeLeft == deviceOrientation {
                    radian = M_PI_2
                }else if .LandscapeRight == deviceOrientation {
                    radian = -M_PI_2
                }else if .PortraitUpsideDown == deviceOrientation {
                    radian = M_PI
                }
                if 0 == radian {
                    self.transform = CGAffineTransformIdentity
                }else {
                    self.transform = CGAffineTransformMakeRotation(CGFloat(radian))
                }
                
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    let deviceOrientation = self?.deviceOrientation ?? .Portrait
                    let transform = self?.transform ?? CGAffineTransformIdentity
                    let handlers = self?.accelerometerHandlers ?? [:]
                    for (_, handler) in handlers {
                        handler(deviceOrientation, transform)
                    }
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    func addAccelerometerHandler(id id: String, handler: DDMotionManagerAccelerometerHandler) {
        self.accelerometerHandlers[id] = handler
    }
    
    func removeAccelerometerHandler(id id: String) {
        self.accelerometerHandlers.removeValueForKey(id)
    }
}