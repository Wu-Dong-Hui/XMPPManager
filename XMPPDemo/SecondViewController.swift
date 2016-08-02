//
//  SecondViewController.swift
//  XMPPDemo
//
//  Created by Roy on 16/5/26.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ZPIMChatManagerDelegate {
    var tableView: UITableView!
    var models = [ChatModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: view.bounds, style: .Plain)
        view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
        
        ZPIMClient.sharedClient.chatManager.addDelegate(self, delegateQueue: dispatch_get_global_queue(0, 0))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let m = models[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatCell)) as! ChatCell
        
        cell.textLabel?.text = m.from + "->" + m.to
        cell.detailTextLabel?.text = m.message
        return cell
    }
    //MARK: - ZPIMChatManagerDelegate
    func didReceiveMessages(messages: Array<ZPIMMessage>) {
        for msg in messages {
            let model = ChatModel()
            model.from = msg.from
            model.to = msg.to
            if let textMsgBody = msg.body as? ZPIMTextMessageBody {
                model.message = textMsgBody.text
            }
            models.append(model)
        }
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadData()
        }
        
    }
    //MARK: - deinit
    deinit {
        ZPIMClient.sharedClient.chatManager.removeDelegate(self)
    }
}

class ChatCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.systemFontOfSize(12)
        detailTextLabel?.font = UIFont.systemFontOfSize(14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChatModel: NSObject {
    var from: String = ""
    var to: String = ""
    var message: String = ""
}