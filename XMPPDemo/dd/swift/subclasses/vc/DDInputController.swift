//
//  DDInputController.swift
//  Dong
//
//  Created by darkdong on 15/4/2.
//  Copyright (c) 2015年 Dong. All rights reserved.
//

import UIKit

class DDInputController: UIViewController {
    enum SourceInput {
        case TextField(UITextField!, ((String!) -> Void)!)
        case TextView(DDInputTextView!, ((String!) -> Void)!)
        case Date(UIDatePicker!, ((NSDate!) -> Void)!)
        case OptionButton(DDOptionButton!, ((AnyObject) -> Void)!)
    }
    var sourceInput: SourceInput = .TextField(nil, nil)
    
    override func loadView() {
        let keyboardView = DDKeyboardView(frame: UIScreen.mainScreen().bounds)
        keyboardView.shouldOffsetContentWhenKeyboardShow = false
        keyboardView.shouldDismissKeyboardByGesture = false
        self.view = keyboardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: #selector(DDInputController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(DDInputController.done))

        self.view.backgroundColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view.
        switch self.sourceInput {
        case let .TextField(textField, _):
            textField.addTarget(self, action: #selector(DDInputController.done), forControlEvents: .EditingDidEndOnExit)
            self.view.addSubview(textField)
        case let .TextView(textView, _):
            textView.didFinishHandler = { [weak self] itv in
                self?.done()
                return
            }
            self.view.addSubview(textView)
        case let .Date(picker, _):
            self.view.addSubview(picker)
        case let .OptionButton(optionButton, _):
//            optionButton.optionDidSelectHandler = { [weak self] btn in
//                self?.done()
//                return
//            }
            self.view.addSubview(optionButton)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var inputTextView: UIView! = nil
        switch self.sourceInput {
        case let .TextField(textField, _):
            inputTextView = textField
        case let .TextView(textView, _):
            inputTextView = textView
        default:
            break
        }
        
        inputTextView?.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        if let nc = self.navigationController {
            nc.popViewControllerAnimated(true)
        } else if self.presentingViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        
    }
    
    func done() {
        switch self.sourceInput {
        case let .TextField(textField, handler):
            handler?(textField.text)
        case let .TextView(textView, handler):
            handler?(textView.text)
        case let .Date(picker, handler):
            handler?(picker.date)
        case let .OptionButton(optionButton, handler):
            handler?(optionButton.selectedButton)
        }
        self.cancel()
    }
}
