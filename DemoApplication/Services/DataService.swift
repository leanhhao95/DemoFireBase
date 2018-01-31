//
//  DataService.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/26/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
import Firebase
class DataServices {
    static var share: DataServices = DataServices()
    let ref = Database.database().reference(withPath: "Danh Sách Nhân Viên")
    let usersRef = Database.database().reference(withPath: "online")
    private var userHandle: DatabaseHandle?
    private var _user: Users!
    var nameDisplay: String = ""
    var senderID: String = ""
    var email: String = ""
    var user: Users! {
        get {
        if _user == nil {
            getInfoUser()
        }
        return _user
        }
        set {
            _user = newValue
        }
    }
    private  var _items: [ListModel]?
    var items: [ListModel]! {
        get {
            if _items == nil {
                observerRef()
            }
            return _items
        }
        set {
            _items = newValue
        }
    }
    func getInfoUser() {
        // thêm user và xoá user đã offline
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self._user = Users(authData: user)
            let currentUserRef = self.usersRef.child(self._user.uid)
            currentUserRef.setValue(self._user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    func observerRef() {
        ref.queryOrdered(byChild: "position").observe(.value, with: { snapshot in
            self._items = []
            for item in snapshot.children {
                let listItem = ListModel(snapshot: item as! DataSnapshot)
                self._items?.append(listItem)
                NotificationCenter.default.post(name: .sendItem, object: nil)
            }
        })
    }
    func checkLogin(completeHandle: @escaping () -> Void) {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil{
               self.senderID = (Auth.auth().currentUser?.uid)!
              self.email = (Auth.auth().currentUser?.email)!
               completeHandle()
            }
        }
    }

    func signIn(email: String, passWord: String) {
        Auth.auth().signIn(withEmail: email,
                           password: passWord)
    }
    func signUp(email: String, passWord: String, completeHandle: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email,
                               password: passWord)
        { user, error in
            if error == nil {
              completeHandle()
            }
        }
    }
}
