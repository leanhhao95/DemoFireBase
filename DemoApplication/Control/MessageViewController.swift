//
//  MessageViewController.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/26/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase
class MessageViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTextView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var senderDisplayName = ""
    var senderId = ""
    var channel: Channel?
    var date = Date()
    var messages = [Message]()
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       title = channel?.name
         registerNotification()
        messageService.getListChat()
        messageService.observeMessages()
       
    }
    // observer notification
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .itemMessage , object: nil)
    }
    @objc func reloadData() {
        messages = messageService.messages
        tableView.reloadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellItentifier = messages[indexPath.row].displayName == self.senderDisplayName ? "sentCell" : "reciveCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellItentifier, for: indexPath) as! CustomCell
        cell.textView.text = messages[indexPath.row].text
        cell.displayName.text = "sender: \(messages[indexPath.row].displayName)"
        return cell
    }
    // Action
    @IBAction func sendDataButton(_ sender: UIButton) {
        messageService.didPressSend(sender, withMessageText: messageTextField.text, senderId: senderId, senderDisplayName: senderDisplayName, date: date, completeHandle:
            {
                self.messageTextField.text = ""
        })
    }
    // Support
    func scrollToLastMessage() {
        if messages.count != 0 {
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                let indexPath = IndexPath(item: self.messages.count - 1 , section: 0)
                self.tableView.scrollToRow(at: indexPath , at: .bottom, animated: true)
            })
        }
    }
    

}
