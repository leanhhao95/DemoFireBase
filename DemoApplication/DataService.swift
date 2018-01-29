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
    var nameDisplay: String = ""
    var senderID: String = ""
    var email: String = ""
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
