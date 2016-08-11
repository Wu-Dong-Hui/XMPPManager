//
//  AppDelegate.swift
//  XMPPDemo
//
//  Created by Roy on 16/5/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let log = DDTTYLogger.sharedInstance()
        log.colorsEnabled = true
        log.logFormatter = LumberjackTTYFormatter()
        
        log.setForegroundColor(UIColor.redColor(), backgroundColor: UIColor.clearColor(), forFlag: DDLogFlag.Error)
        log.setForegroundColor(UIColor.blueColor(), backgroundColor: UIColor.clearColor(), forFlag: DDLogFlag.Info)
        log.setForegroundColor(UIColor.yellowColor(), backgroundColor: UIColor.clearColor(), forFlag: DDLogFlag.Warning)
        log.setForegroundColor(UIColor.greenColor(), backgroundColor: UIColor.clearColor(), forFlag: DDLogFlag.Debug)
        log.setForegroundColor(UIColor.brownColor(), backgroundColor: UIColor.clearColor(), forFlag: DDLogFlag.Verbose)
        DDLog.addLogger(log)
        
        
        let options = ZPIMOptions()
        let client = ZPIMClient.sharedClient
        let error = client.initialize(options)
        
        if let err = error {
            DDLogError("\(err.code): " + err.description);
        }
        if let user = client.getUserName(), let pw = client.getPassword() {
            login(user, password: pw)
        } else {
            client.setUserName("test1")
            client.setPassword("admin")
            login("test1", password: "admin")
        }
        DDLogDebug(NSTemporaryDirectory())
        return true
    }
    func login(user: String, password: String) {
        ZPIMClient.sharedClient.login(user, password: password, completion: { (error) in
            if let err = error {
                DDLogError(err.description)
            }
        })
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

