//
//  DDNavigationBar.swift
//  Dong
//
//  Created by darkdong on 15/3/28.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

typealias DDBarButtonItemHandler = (UIBarButtonItem!) -> Void

class DDNavigationBar: UINavigationBar, UINavigationBarDelegate {
//    struct Static {
//        static var subtitleTextAttributes: [NSObject: AnyObject]! = nil
//    }
    weak var vc: UIViewController!
    var shouldShowBackArrowOnly = false
    var backItemTitle: String!
//    var vcNavigationItem: UINavigationItem!
//    var centerItem: UINavigationItem! {
//        return self.items.last as! UINavigationItem
//    }
    var leftItemHandler: DDBarButtonItemHandler?
    var rightItemHandler: DDBarButtonItemHandler?
    var willPopHandler: (() -> Void)?
    
    private func commonInit() {
        let appearance = UINavigationBar.appearance()
        self.setBackgroundImage(appearance.backgroundImageForBarMetrics(.Default), forBarMetrics: .Default)
        self.titleTextAttributes = appearance.titleTextAttributes
        self.tintColor = appearance.tintColor
        
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    init(viewController: UIViewController!, shouldShowBackArrowOnly: Bool = false) {
        let frame = CGRect(x: 0, y: 0, width: viewController.view.width, height: 64)
        super.init(frame: frame)
        self.commonInit()
        self.vc = viewController
        self.shouldShowBackArrowOnly = shouldShowBackArrowOnly
//        DDLog2.print("DDNavigationBar navigationItem \(viewController.navigationItem) title: \(viewController.navigationItem.title)")
//        if let items = viewController.navigationController?.navigationBar.items {
//            for item in items {
//                DDLog2.print("DDNavigationBar item: \(item) title: \(item.title)")
//            }
//        }
        
//        if let sysBackItem = viewController.navigationController?.navigationBar.items.last as? UINavigationItem {
////            DDLog2.print("sysBackItem \(sysBackItem) \(sysBackItem.title)")
//            
//            self.backItemTitle = sysBackItem.title
//            var items = [UINavigationItem]()
//            let sysCenterItem = viewController.navigationItem
////            DDLog2.print("sysCenterItem \(sysCenterItem) \(sysCenterItem.title)")
//            
//            if sysBackItem !== sysCenterItem {
//                let title = shouldShowBackArrowOnly ? "" : sysBackItem.title
//                let backItem = UINavigationItem(title: title)
//                items.append(backItem)
//            }
//            
//            let centerItem = UINavigationItem(title: sysCenterItem.title)
//            items.append(centerItem)
//            
//            self.items = items
//            
////            DDLog2.print("self.backItem \(self.backItem) \(self.backItem?.title)")
////            DDLog2.print("self.topItem \(self.topItem) \(self.topItem?.title)")
//        }
    }

    //MARK: public
    func setLeftButton(button: UIButton!) {
        button.frame = CGRect(x: 0, y: 20, width: 80, height: 44)
        button.layoutContentLeftmost()
        let barButtonItem = UIBarButtonItem(customView: button)
        //set system navigation bar
        self.vc.navigationItem.leftBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.leftBarButtonItem = barButtonItem
    }
    
    func setLeftItemWithTitle(title: String!, handler: DDBarButtonItemHandler!) {
        let barButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: #selector(DDNavigationBar.leftItemClicked))
        //set system navigation bar
        self.vc.navigationItem.leftBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.leftBarButtonItem = barButtonItem
        self.leftItemHandler = handler
    }
    
    func setLeftItemWithImage(image: UIImage!, handler: DDBarButtonItemHandler!) {
        let barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(DDNavigationBar.leftItemClicked))
        //set system navigation bar
        self.vc.navigationItem.leftBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.leftBarButtonItem = barButtonItem
        self.leftItemHandler = handler
    }
    
    func setRightButton(button: UIButton!) {
        button.frame = CGRect(x: self.width - 80, y: 20, width: 80, height: 44)
        button.layoutContentRightmost()
        let barButtonItem = UIBarButtonItem(customView: button)
        //set system navigation bar
        self.vc.navigationItem.rightBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.rightBarButtonItem = barButtonItem
    }
    
    func setRightItemWithTitle(title: String!, handler: DDBarButtonItemHandler!) {
        let barButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: #selector(DDNavigationBar.rightItemClicked))
        //set system navigation bar
        self.vc.navigationItem.rightBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.rightBarButtonItem = barButtonItem
        self.rightItemHandler = handler
    }
    
    func setRightItemWithImage(image: UIImage!, handler: DDBarButtonItemHandler!) {
        let barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(DDNavigationBar.rightItemClicked))
        //set system navigation bar
        self.vc.navigationItem.rightBarButtonItem = barButtonItem
        //sync to my own navigation bar
        self.topItem?.rightBarButtonItem = barButtonItem
        self.rightItemHandler = handler
    }
    
    //MARK: private
    func leftItemClicked() {
        DDLog2.print("leftItemClicked")
        self.leftItemHandler?(self.topItem?.leftBarButtonItem)
    }
    
    func rightItemClicked() {
        self.rightItemHandler?(self.topItem?.rightBarButtonItem)
    }
    
    //MARK: UINavigationBarDelegate
    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        DDLog2.print("UINavigationBarDelegate shouldPopItem")
        self.willPopHandler?()
        self.vc.navigationController?.popViewControllerAnimated(true)
        return true
    }
}
