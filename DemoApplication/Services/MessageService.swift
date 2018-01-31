//
//  MessageService.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/31/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
import Firebase
class MesssageService {
    static let shared : MesssageService = MesssageService()
    var channelRef: DatabaseReference?
    lazy var messageRef: DatabaseReference! = self.channelRef!.child("messages")
    private var _messages: [Message]?
    var messages: [Message]! {
        get {
            if _messages == nil {
                getListChat()
            }
            return _messages
        }
        set {
            _messages = newValue
        }
    }
    func getListChat() {
        messageRef = channelRef!.child("messages")
        messageRef.queryOrdered(byChild: "name").observe(.value) { (snapshot) in
            self._messages = []
            for item in snapshot.children {
                let listItem = Message(snapshot: item as! DataSnapshot)
                self._messages?.append(listItem)
                NotificationCenter.default.post(name: .itemMessage, object: nil)
            }
        }
    }
    func observeMessages() {
        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25) // 1 tạo một truy vấn đồng bộ hoá tới 25 tin nhắn cuối cùng
        // tin nhắn sẽ được ghi vào fb
        messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // trích xuất data từ snapshot
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text) // thêm tin nhắn mới vào data source
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    private func addMessage(withId id: String, name: String, text: String) {
        let message = Message(senderId: id, displayName: name, text: text, key: "")
        self._messages?.append(message)
    }
    // gửi tin nhắn
    func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!, completeHandle: @escaping () -> Void) {
        messageRef = channelRef!.child("messages")
        let itemRef = messageRef.childByAutoId() // tạo một tham thiếu với 1 unique key
        let messageItem = [ // tạo một dict để biểu diễn tin nhắn
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        if text != "" {
        itemRef.setValue(messageItem) // lưu dữ liệu tại vị trí child mới
        }
        completeHandle()
    }
    func resetAllValue() {
        messageRef = nil
        messages.removeAll()
        _messages?.removeAll()
    }
}
