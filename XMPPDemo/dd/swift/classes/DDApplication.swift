//
//  DDApplication.swift
//  Dong
//
//  Created by darkdong on 15/8/22.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDApplication: UIApplication {
    override func sendEvent(event: UIEvent) {
        super.sendEvent(event)
        
        //patch for bug: bars in bottom left of screen does't receive touch begin event immediately
        if let touches = event.allTouches(), touch = touches.first, view = touch.view where touch.phase == .Began && view is DDInputVoiceView {
            let info: [String: AnyObject] = [
                DDNotificationInfoKeyEvent: event
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(DDNotificationNameInputVoiceViewTouchesBegan, object: view, userInfo: info)
        }
    }
}
