//
//  Message.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/26/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
import Firebase
class Message {
    var key: String
    var senderId : String
    var displayName: String
    var text: String
    var ref: DatabaseReference?
//    init(senderId: String, senderDisplayName: String, text: String) {
//        self.senderId = senderId
//        self.senderDisplayName = senderDisplayName
//        self.text = text
//    }
    init(senderId: String, displayName: String, text: String, key: String = "") {
        self.key = key
        self.senderId = senderId
        self.displayName = displayName
        self.text = text
    }
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        displayName = snapshotValue["senderName"] as! String
        text = snapshotValue["text"]    as! String
        senderId = snapshotValue["senderId"] as! String
        ref = snapshot.ref
    }
}
