//
//  ChatViewController.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/25/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
// là một UICollectionVC hỗ trợ việc chat
class ChatViewController: JSQMessagesViewController {
    var channelRef: DatabaseReference?
    var channel: Channel?
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    private lazy var usersTypingQuery: DatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = channel?.name
        observeMessages()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
        finishReceivingMessage()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
    }
    // trả về số lượng item trong mỗi section
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    // tạo hình ảnh với các thư đi và thư gửi outgoing messages hiển thị bên phải và imcoming hiển thị bên trái.
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    // setting the bubble images
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // lấy ra các tin nhắn
        if message.senderId == senderId { // nếu tin nhắn là của local user hiển thị bên phải
            return outgoingBubbleImageView
        } else { // ngược lại hiển thị bên trái
            return incomingBubbleImageView
        }
    }
    // hỗ trợ avatar
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    // tạo messages
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
  
    // set text view của bubble
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
           
        }
        return cell
    }
    
    // gửi tin nhắn
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // tạo một tham thiếu với 1 unique key
        let messageItem = [ // tạo một dict để biểu diễn tin nhắn
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // lưu dữ liệu tại vị trí child mới
        isTyping = false // reset typing sau khi ấn nút send
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // phát ra âm thanh tin nhắn đã gửi
        
        finishSendingMessage() // hoàn thành gửi và hiển thị trên firebase
    }
    // đồng bộ dữ liệu với datasource
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
       
        let messageQuery = messageRef.queryLimited(toLast:25) // 1 tạo một truy vấn đồng bộ hoá tới 25 tin nhắn cuối cùng
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // trích xuất data từ snapshot
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text) // thêm tin nhắn mới vào data source
                self.finishReceivingMessage()  // thông báo rằng đã nhân được tin nhắn
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    // extension
    // khi một người sử dụng gõ
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        print(textView.text != "")
    }
    private lazy var userIsTypingRef: DatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId) // tạo một tham chiếu fb để kiểm tra xem người dùng có gõ hay không
    private var localTyping = false //
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // cập nhật localtyping và userIstyping mỗi khi nó thay đổi
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator") // tạo một tham chiếu đến channel typingIndicator
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        //
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // 2 nếu chỉ có 1 người gõ không show indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // 3 check xem có nhiều người gõ k
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
}
