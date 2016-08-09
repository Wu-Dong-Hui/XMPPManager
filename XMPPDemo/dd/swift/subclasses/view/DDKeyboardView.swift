//
//  DDKeyboardView.swift
//  Dong
//
//  Created by darkdong on 15/3/13.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDKeyboardView: UIScrollView, UIGestureRecognizerDelegate {
    static var log: DDLog2 = {
        let log = DDLog2()
        log.enabled = false
        return log
    }()
    
    //keyboard has shown
    var keyboardDidShow = false
    var keyboardRect: CGRect!
    var deltaY: CGFloat = 0
    
    //remember my original geometry for restore
    var originalKeyboardViewFrame: CGRect!

    //remember editor to calculate distance to push
    var activeTextView: UIView!
    var initialRectOfActiveTextView: CGRect!

    var shouldOffsetContentWhenKeyboardShow = true
    var shouldDismissKeyboardByGesture = true
    
    //if editor is in a scrollview(not DDKeyboardView itself), we should push that scrollview by changing it's contentOffset
    var targetScrollView: UIScrollView?
    var initialContentOffsetOfTargetScrollView: CGPoint?
    
    //additional spacing between active text view bottom and keyboard top
    var additionalSpacing: CGFloat = 0

    //keyboard duration may be 0 on subsequent keyboardWillShow notification, so we should remember the first non-zero duration for animation
    var firstDuration: NSTimeInterval = 0
    
    //gesture to dismiss keyboard
    var tapGestureToDismissKeyboard: UITapGestureRecognizer!
    var panGestureToDismissKeyboard: UIPanGestureRecognizer!
    
    var keyboardWillShowObserver: NSObjectProtocol?
    var keyboardDidShowObserver: NSObjectProtocol?
    var keyboardWillHideObserver: NSObjectProtocol?
    var keyboardDidHideObserver: NSObjectProtocol?

    var keyboardWillShowHandler: ((UIView!) -> Void)?
    var keyboardWillHideHandler: ((UIView!) -> Void)?
    
    var dismissKeyboardHandler: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clickableColor
        
        let action = NSSelectorFromString("checkGestureToDismissKeyboard:")
        
        tapGestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: action)
        tapGestureToDismissKeyboard.enabled = false
        tapGestureToDismissKeyboard.delegate = self
        self.addGestureRecognizer(tapGestureToDismissKeyboard)

        panGestureToDismissKeyboard = UIPanGestureRecognizer(target: self, action: action)
        panGestureToDismissKeyboard.enabled = false
        panGestureToDismissKeyboard.delegate = self
        self.addGestureRecognizer(panGestureToDismissKeyboard)
        
        keyboardWillShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            DDKeyboardView.log.print("UIKeyboardWillShowNotification")
            self?.handleKeyboardWillShow(notification)
        }
        keyboardDidShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            DDKeyboardView.log.print("UIKeyboardDidShowNotification")
            self?.keyboardDidShow = true
            self?.tapGestureToDismissKeyboard.enabled = true
            self?.panGestureToDismissKeyboard.enabled = true
        }
        keyboardWillHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            DDKeyboardView.log.print("UIKeyboardWillHideNotification")
            self?.handleKeyboardWillHide(notification)
        }
        keyboardDidHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: nil) { (notification) -> Void in
            DDKeyboardView.log.print("UIKeyboardDidHideNotification")
        }
    }
    
    deinit {
        DDKeyboardView.log.print("DDKeyboardView deinit")
        if let observer = keyboardWillShowObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = keyboardDidShowObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = keyboardWillHideObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = keyboardDidHideObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func checkGestureToDismissKeyboard(gesture: UIGestureRecognizer!) {
        if shouldDismissKeyboardByGesture && keyboardDidShow {
            if (gesture as? UIPanGestureRecognizer) != nil {
                DDKeyboardView.log.print("DDKeyboardView dismissKeyboard by pan gesture")
                dismissKeyboard()
            }else if (gesture as? UITapGestureRecognizer) != nil {
                //                if tap === self.tapGestureToDismissKeyboard {
                DDKeyboardView.log.print("DDKeyboardView dismissKeyboard by tap gesture")
                dismissKeyboard()
            }else if gesture == nil {
                DDKeyboardView.log.print("DDKeyboardView dismissKeyboard programmatically")
                dismissKeyboard()
            }
        }
    }
    
    func dismissKeyboard() {
        if let handler = dismissKeyboardHandler {
            handler()
        }else {
            endEditing(true)
        }
    }
    
    //MARK: - private
    func handleKeyboardWillShow(notification: NSNotification) {
        if !keyboardDidShow {
            //check if active text view is in keybaord view once
            activeTextView = activeTextViewInView(self)
        }
        
        if activeTextView == nil {
            //first responder is not my text view
            DDKeyboardView.log.print("no activeTextView, return")
            return
        }
        
        DDKeyboardView.log.print("activeTextView \(activeTextView)")
        
        let keyboardInfo = notification.userInfo!
        keyboardRect = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        var duration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        
        DDKeyboardView.log.print("keyboardRect \(keyboardRect)")
        
        if !keyboardDidShow {
            //init once
            if targetScrollView == nil {
                targetScrollView = superScrollViewContainingTextView(activeTextView)
            }
            if let scrollView = targetScrollView {
                initialContentOffsetOfTargetScrollView = scrollView.contentOffset
            }
            
            initialRectOfActiveTextView = activeTextView.convertRect(activeTextView.boundsRect, toView: nil)
            firstDuration = duration
        }
        
        if CGRectIsEmpty(keyboardRect) {
            //                DDKeyboardView.log.print("keyboardRect is empty")
            return
        }
        
        if duration == 0 {
            duration = firstDuration
        }
//        let curve = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
//        let options = UIViewAnimationOptions(rawValue: curve)
        
        deltaY = CGRectGetMinY(keyboardRect) - additionalSpacing - CGRectGetMaxY(initialRectOfActiveTextView)
        
        DDKeyboardView.log.print("deltaY \(deltaY)")
        
        if shouldOffsetContentWhenKeyboardShow {
            DDKeyboardView.log.print("shouldOffsetContentWhenKeyboardShow")
            if let scrollView = targetScrollView {
                DDKeyboardView.log.print("offset content of UIScrollView \(scrollView)")
                let oldContentOffset = initialContentOffsetOfTargetScrollView!
                var newContentOffset = CGPoint(x: oldContentOffset.x, y: oldContentOffset.y - deltaY)
                
                if newContentOffset.y < 0 {
                    newContentOffset.y = 0
                }
                scrollView.setContentOffset(newContentOffset, animated: true)
            }else {
                DDKeyboardView.log.print("offset content of DDKeyboardView")
                var newContentOffset = CGPoint(x: 0, y: -deltaY)
                if newContentOffset.y < 0 {
                    newContentOffset.y = 0
                }
                setContentOffset(newContentOffset, animated: true)
            }
        }
        
        keyboardWillShowHandler?(self.activeTextView)
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        keyboardDidShow = false
        tapGestureToDismissKeyboard.enabled = false
        panGestureToDismissKeyboard.enabled = false
        
        if shouldOffsetContentWhenKeyboardShow {
            if let scrollView = targetScrollView {
                scrollView.setContentOffset(initialContentOffsetOfTargetScrollView!, animated: true)
            }else {
                contentOffset = CGPointZero
            }
        }
        
        keyboardWillHideHandler?(activeTextView)
    }
    
    func superScrollViewContainingTextView(view: UIView!) -> UIScrollView? {
        while let superview = view.superview {
//            if let supersuperview = superview.superview where supersuperview is UITableViewCell {
//                //skip UITableViewCellScrollView in iOS7
//                return superScrollViewContainingTextView(superview)
//            }
            if superview is UIScrollView && superview != self && superview.className() != "UITableViewCell" && superview.className() != "UITableViewWrapperView" {
                return superview as? UIScrollView
            }else {
                return superScrollViewContainingTextView(superview)
            }
        }
        return nil
    }
    
    //MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        DDKeyboardView.log.print("DDKeyboardView gestureRecognizer \(gestureRecognizer) shouldReceiveTouch \(touch)")
//        if gestureRecognizer === self.tapGestureToDismissKeyboard || gestureRecognizer === self.panGestureToDismissKeyboard {
//            DDKeyboardView.log.print("is my gesture")
            if touch.view is UINavigationBar {
//                DDKeyboardView.log.print("touch view is UINavigationBar")
                return false
            }
//        }
        return true
    }
}

private func activeTextViewInView(view: UIView!) -> UIView! {
    if view.isFirstResponder() {
        return view
    }else {
        for subview in view.subviews {
            if let view = activeTextViewInView(subview) {
                return view
            }
        }
        return nil
    }
}
