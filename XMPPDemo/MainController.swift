//
//  MainController.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/6.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class MainController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController.isKindOfClass(SecondViewController) || viewController.isKindOfClass(ConversationsController) {
            if let _ = ZPIMClient.sharedClient.getUserName() {
                return true
            } else {
                DDLogError("login failed please relogin")
                return false
            }
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
