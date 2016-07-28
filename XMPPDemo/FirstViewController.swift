//
//  FirstViewController.swift
//  XMPPDemo
//
//  Created by Roy on 16/5/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func connectClicked(sender: UIButton) {
        let host = hostTextField.text!
        let port = UInt16(portTextField.text!)!
        
        ZPIMClient.sharedClient.connect(host, port: port)
    }
    @IBAction func loginClicked(sender: UIButton) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

