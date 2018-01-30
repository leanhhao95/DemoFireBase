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
    var channelRef: DatabaseReference?
    var channel: Channel?
    var date = Date()
    
    var messages = [Message]()
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
         observeMessages()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       title = channel?.name
        messageRef.queryOrdered(byChild: "name").observe(.value) { (snapshot) in
            var newItems: [Message] = []
            for item in snapshot.children {
                let listItem = Message(snapshot: item as! DataSnapshot)
                newItems.append(listItem)
            }
            self.messages = newItems
            self.tableView.reloadData()
        }
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
//        let cellIdentifier = chatHistory![indexPath.row].is_own == true ? "sentCell" : "reciveCell"
        let cellItentifier = messages[indexPath.row].displayName == self.senderDisplayName ? "sentCell" : "reciveCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellItentifier, for: indexPath) as! CustomCell
        cell.textView.text = messages[indexPath.row].text
        cell.displayName.text = "sender: \(messages[indexPath.row].displayName)"
        return cell
    }
    // đồng bộ dữ liệu với datasource
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        
        let messageQuery = messageRef.queryLimited(toLast:25) // 1 tạo một truy vấn đồng bộ hoá tới 25 tin nhắn cuối cùng
        // 2. We can use the observe method to listen for new
        // tin nhắn sẽ được ghi vào fb
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // trích xuất data từ snapshot
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text) // thêm tin nhắn mới vào data source
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    // tạo messages
    private func addMessage(withId id: String, name: String, text: String) {
        let message = Message(senderId: id, displayName: name, text: text, key: "")
            messages.append(message)
    }
    // gửi tin nhắn
    func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // tạo một tham thiếu với 1 unique key
        let messageItem = [ // tạo một dict để biểu diễn tin nhắn
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        itemRef.setValue(messageItem) // lưu dữ liệu tại vị trí child mới
    }
    
    // Action
    @IBAction func sendDataButton(_ sender: UIButton) {
        didPressSend(sender, withMessageText: messageTextField.text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
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
