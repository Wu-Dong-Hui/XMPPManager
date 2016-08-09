//
//  UINavigationControllerExtension.swift
//  Dong
//
//  Created by mol on 14/12/22.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func pushViewControllerFromBottom2Top(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        transition.delegate = self
        self.view.layer.addAnimation(transition, forKey: "pushViewController")
        self.pushViewController(viewController, animated: false)
    }
    
    func popViewControllerFromTop2Bottom() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        self.view.layer.addAnimation(transition, forKey: "popViewController")
        self.popViewControllerAnimated(false)
    }
}