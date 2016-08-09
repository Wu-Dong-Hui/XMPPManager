//
//  DDKeyboardObserver.swift
//  Dong
//
//  Created by darkdong on 15/10/19.
//  Copyright © 2015年 Dong. All rights reserved.
//

import UIKit

private func focusViewInView(view: UIView) -> UIView? {
    if view.isFirstResponder() {
        return view
    }else {
        for subview in view.subviews {
            if let view = focusViewInView(subview) {
                return view
            }
        }
        return nil
    }
}

class DDKeyboardObserver: NSObject, UIGestureRecognizerDelegate {
    static var log: DDLog2 = {
        let log = DDLog2()
        log.enabled = false
        return log
        }()
    
    var shouldShiftAutomatically = true
    var shouldDismissKeyboardByGesture = true
    
    var containerView: UIView
    var additionalSpacing: CGFloat = 0

    var focusView: UIView?
    var shiftView: UIView?
    var shiftViewFrame: CGRect?
    var shiftViewContentOffset: CGPoint?
    var shiftViewContentInsets: UIEdgeInsets?

    var keyboardInfo: [NSObject: AnyObject]?
    var deltaY: CGFloat?
    
    var isKeyboardShowing: Bool {
        return keyboardInfo != nil
    }
    
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardDidShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
    private var keyboardDidHideObserver: NSObjectProtocol?
    
    var keyboardWillShowHandler: ((UIView, CGFloat) -> Void)?
    var keyboardWillHideHandler: ((UIView, CGFloat) -> Void)?
    var dismissKeyboardHandler: (() -> Void)?
    
    //gesture to dismiss keyboard
    var tapGestureToDismissKeyboard: UITapGestureRecognizer!
    var panGestureToDismissKeyboard: UIPanGestureRecognizer!
    
    init(containerView: UIView) {
        self.containerView = containerView
        
        super.init()
        
        let action = NSSelectorFromString("checkGestureToDismissKeyboard:")
        
        tapGestureToDismissKeyboard = UITapGestureRecognizer(target: self, action: action)
        tapGestureToDismissKeyboard.enabled = false
        tapGestureToDismissKeyboard.delegate = self
        containerView.addGestureRecognizer(tapGestureToDismissKeyboard)
        
        panGestureToDismissKeyboard = UIPanGestureRecognizer(target: self, action: action)
        panGestureToDismissKeyboard.enabled = false
        panGestureToDismissKeyboard.delegate = self
        containerView.addGestureRecognizer(panGestureToDismissKeyboard)
        
        keyboardWillShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            DDKeyboardObserver.log.print("DDKeyboardObserver: UIKeyboardWillShowNotification")
            self?.handleKeyboardWillShow(notification)
        }
        keyboardDidShowObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            //            DDKeyboardObserver.log.print("DDKeyboardObserver: UIKeyboardDidShowNotification")
            self?.handleKeyboardDidShow(notification)
        }
        keyboardWillHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            DDKeyboardObserver.log.print("DDKeyboardObserver: UIKeyboardWillHideNotification")
            self?.handleKeyboardWillHide(notification)
        }
        keyboardDidHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: nil) { [weak self] (notification) -> Void in
            //            DDKeyboardObserver.log.print("DDKeyboardObserver: UIKeyboardDidHideNotification")
            self?.handleKeyboardDidHide(notification)
        }
    }
    
    deinit {
        DDKeyboardObserver.log.print("DDKeyboardObserver: deinit")
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
    
    //MARK: - private
    private
    func handleKeyboardWillShow(notification: NSNotification) {
        guard let focusView = focusViewInView(containerView), keyboardInfo = notification.userInfo, keyboardRectValue = keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        self.keyboardInfo = keyboardInfo
        let keyboardRect = keyboardRectValue.CGRectValue()
        if CGRectIsEmpty(keyboardRect) {
            DDKeyboardObserver.log.print("DDKeyboardObserver: keyboardRect is empty")
            return
        }
        
        DDKeyboardObserver.log.print("DDKeyboardObserver: focusView \(focusView)")
        self.focusView = focusView
        
        //find the view to shift
        let oldShiftView = shiftView
        if shiftView == nil {
            if let enclosingScrollView = scrollViewThatEncloseFocusView(focusView) {
                DDKeyboardObserver.log.print("DDKeyboardObserver: shiftView is UIScrollView")
                shiftView = enclosingScrollView
            }
        }
        
        if shiftView == nil {
            DDKeyboardObserver.log.print("DDKeyboardObserver: shiftView is rootView")
            shiftView = containerView
        }
        
        DDKeyboardObserver.log.print("DDKeyboardObserver: \nshiftView \(shiftView) \noldShiftView \(oldShiftView)")
        
        if shiftView != oldShiftView || shiftViewFrame == nil {
            //save shift view info only if change or no info
            shiftViewFrame = shiftView!.frame
            DDKeyboardObserver.log.print("DDKeyboardObserver: shiftViewFrame \(shiftViewFrame)")
            
            if let scrollView = shiftView as? UIScrollView {
                shiftViewContentOffset = scrollView.contentOffset
                shiftViewContentInsets = scrollView.contentInset
                DDKeyboardObserver.log.print("DDKeyboardObserver: shiftViewContentOffset \(shiftViewContentOffset) shiftViewContentInsets \(shiftViewContentInsets)")
            }
        }
        
        let focusViewRect = focusView.convertRect(focusView.boundsRect, toView: nil)
        let deltaY = keyboardRect.minY - additionalSpacing - focusViewRect.maxY
        
        self.deltaY = deltaY
        
        if shouldShiftAutomatically {
            DDKeyboardObserver.log.print("DDKeyboardObserver: autoMoveWhenKeyboardShowing \(deltaY)")
            shift(restoring: false)
        }
        keyboardWillShowHandler?(focusView, deltaY)
    }
    
    func handleKeyboardDidShow(notification: NSNotification) {
        tapGestureToDismissKeyboard.enabled = true
        panGestureToDismissKeyboard.enabled = true
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        tapGestureToDismissKeyboard.enabled = false
        panGestureToDismissKeyboard.enabled = false
        
        if shouldShiftAutomatically {
            shift(restoring: true)
        }
        
        if let focusView = focusView, deltaY = deltaY {
            keyboardWillHideHandler?(focusView, deltaY)
        }
    }
    
    func handleKeyboardDidHide(notification: NSNotification) {
        keyboardInfo = nil
        deltaY = nil
        focusView = nil
        shiftViewFrame = nil
        shiftViewContentOffset = nil
        shiftViewContentInsets = nil
    }
    
    func shift(restoring isRestoring: Bool) {
        guard let dy = deltaY, view = shiftView else {
            return
        }
        
        if let scrollView = view as? UIScrollView {
            if isRestoring {
                //NOTE: restoring is absolute
                scrollView.setContentOffset(shiftViewContentOffset!, animated: true)
                scrollView.contentInset = shiftViewContentInsets!
            }else {
                //NOTE: pop keyboard is by increament
                var newContentOffset = scrollView.contentOffset
                newContentOffset.y -= dy
                if newContentOffset.y < 0 {
                    newContentOffset.y = 0
                }
                scrollView.setContentOffset(newContentOffset, animated: true)
            }
        }else {
            if isRestoring {
                //NOTE: restoring is absolute
                view.top = shiftViewFrame!.minY
            }else {
                //NOTE: pop keyboard is by increament
                view.top += dy
            }
        }
    }
    
    func checkGestureToDismissKeyboard(gesture: UIGestureRecognizer!) {
        if shouldDismissKeyboardByGesture && isKeyboardShowing {
            dismissKeyboard()
        }
    }
    
    func dismissKeyboard() {
        if let handler = dismissKeyboardHandler {
            handler()
        }else {
            containerView.endEditing(true)
        }
    }
    
    func scrollViewThatEncloseFocusView(view: UIView) -> UIScrollView? {
        while let superview = view.superview {
            if superview is UIScrollView && superview != view && superview.className() != "UITableViewCell" && superview.className() != "UITableViewWrapperView" {
                return superview as? UIScrollView
            }else {
                return scrollViewThatEncloseFocusView(superview)
            }
        }
        return nil
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view is UINavigationBar {
            //            DDKeyboardObserver.log.print("DDKeyboardObserver: touch view is UINavigationBar")
            return false
        }
        return true
    }
}