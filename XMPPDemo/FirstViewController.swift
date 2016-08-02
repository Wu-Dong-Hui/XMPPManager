//
//  FirstViewController.swift
//  XMPPDemo
//
//  Created by Roy on 16/5/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var userField: UITextField!
    
    
    @IBOutlet weak var contextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sendClicked(sender: UIButton) {
        
        guard ZPIMClient.sharedClient.isLoggedin else {
            DDLogError("please login before send any thing")
            return
        }
        guard let user = userField.text where user.characters.count != 0 else {
            DDLogError("user can not be empty")
            return
        }
        guard let context = contextField.text where context.characters.count != 0 else {
            DDLogError("context can not be empty")
            return
        }
        let body = ZPIMTextMessageBody(text: context)
        let message = ZPIMMessage(conversationId: "conversationId", from: ZPIMClient.sharedClient.getUserName()!, to: user, body: body, ext: nil)
        ZPIMClient.sharedClient.chatManager.asyncSendMessage(message, progress: { (progress) -> (Void) in
            
            }) { (message, error) -> (Void) in
                if let msg = message {
                    DDLogInfo(msg.description)
                } else {
                    DDLogError(error.description)
                }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

