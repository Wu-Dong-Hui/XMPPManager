//
//  ConversationsController.swift
//  XMPPDemo
//
//  Created by Roy on 16/8/4.
//  Copyright © 2016年 ZhaoPin. All rights reserved.
//

import UIKit

class ConversationsController: UITableViewController {
    var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        loadConversation()
    }
    func loadConversation() {
        guard let user = ZPIMClient.sharedClient.getUserName() else {
            DDLogError("please login first")
            return
        }
        Utility.get("getFriend", paras: ["jid": user]) { [weak self] (json, error, msg) in
            if json != nil {
                DDLogDebug("\(json)")
                let cs = json as! [[String: AnyObject]]
                for c in cs {
                    let m = Conversation(json: c)
                    self?.conversations.append(m)
                }
                self?.tableView.reloadData()
            } else {
                DDLogError(error.debugDescription)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chat = ChatController()
//        chat.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(chat, animated: true)
        chat.conversation = conversations[indexPath.row]
        let nav = UINavigationController(rootViewController: chat)
        presentViewController(nav, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.conversations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        let m = self.conversations[indexPath.row]
        cell.textLabel?.text = m.nick
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
class Conversation: NSObject {
    private (set) var jid: String!
    private (set) var nick: String!
    private (set) var avatarURL: String?
    init(json: [String: AnyObject]) {
        
        self.jid = json["jid"] as! String
        self.nick = json["nick"] as! String
        self.avatarURL = json["avatar"] as? String
    }
}
