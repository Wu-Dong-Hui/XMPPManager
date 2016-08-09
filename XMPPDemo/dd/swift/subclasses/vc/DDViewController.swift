//
//  DDViewController.swift
//  Dong
//
//  Created by darkdong on 14-8-6.
//  Copyright (c) 2014年 Dong. All rights reserved.
//

import UIKit

class DDViewController: UIViewController {
    var shouldAutoRestoreState = true
    var savedStateStatusBarHidden = UIApplication.sharedApplication().statusBarHidden
    var savedStateStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
    
    var savedStateNavigationBarHidden: Bool?
    var savedStateNavigationBarTransulent: Bool?
    
    var externalTransitionViews: [UIView]?
    var internalTransitionViews: [UIView]?
    var deltaXWhileTransition = UIScreen.mainScreen().bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedStateNavigationBarHidden = self.navigationController?.navigationBar.hidden
        savedStateNavigationBarTransulent = self.navigationController?.navigationBar.translucent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let externalTransitionViews = self.externalTransitionViews {
            //准备externalTransitionViews, 放在正常的位置
            for externalTransitionView in externalTransitionViews {
                externalTransitionView.save()
                self.view.addSubview(externalTransitionView)
            }
            if let internalTransitionViews = self.internalTransitionViews {
                //准备internalTransitionViews,放在画面外
                for internalTransitionView in internalTransitionViews {
                    internalTransitionView.left += self.deltaXWhileTransition
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let externalTransitionViews = self.externalTransitionViews {
            //过场动画,只一次
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                for externalTransitionView in externalTransitionViews {
                    externalTransitionView.left -= self.deltaXWhileTransition
                }
                if let internalTransitionViews = self.internalTransitionViews {
                    for internalTransitionView in internalTransitionViews {
                        internalTransitionView.left -= self.deltaXWhileTransition
                    }
                }
            }, completion: { (finished) -> Void in
                for externalTransitionView in externalTransitionViews {
                    externalTransitionView.restore()
                }
            })
            self.externalTransitionViews = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.shouldAutoRestoreState {
            if let objs = self.navigationController?.viewControllers {
                let vcs: NSArray = objs 
                if vcs.indexOfObjectIdenticalTo(self) == Foundation.NSNotFound {
                    self.restoreUISettings()
                }
            }
        }
    }
    
    func restoreUISettings() {
        UIApplication.sharedApplication().statusBarHidden = self.savedStateStatusBarHidden
        UIApplication.sharedApplication().statusBarStyle = self.savedStateStatusBarStyle
        
        if let savedStateNavigationBarHidden = self.savedStateNavigationBarHidden {
            self.navigationController?.navigationBar.hidden = savedStateNavigationBarHidden
        }
        if let savedStateNavigationBarTransulent = self.savedStateNavigationBarTransulent {
            self.navigationController?.navigationBar.translucent = savedStateNavigationBarTransulent
        }
    }
}
