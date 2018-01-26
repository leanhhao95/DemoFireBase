//
//  ListTableVC.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/25/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase
class ListTableVC: UITableViewController {
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [ListModel] = []
    
    let ref = Database.database().reference(withPath: "Danh Sách Nhân Viên")
    let usersRef = Database.database().reference(withPath: "online")
    var user: Users!
    var userCountBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [ListModel] = []
            
            for item in snapshot.children {
                let listItem = ListModel(snapshot: item as! DataSnapshot)
                newItems.append(listItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
//         kiểm tra login
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = Users(authData: user)
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text =   items[indexPath.row].name
        cell.detailTextLabel?.text =   items[indexPath.row].position
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items[indexPath.row].ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)

    }
    // MARK: Add Item
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        // 1
//                                        guard let firstTextField = alert.textFields[0],let secondTextField = alert.textFields[1],
//                                            let firstText = firstTextField.text, let secondText = secondTextField.text else { return }
                                        let nameText = alert.textFields![0]
                                        let positionText = alert.textFields![1]
                                        guard let firstText = nameText.text, let _ = positionText.text else {return}
                                        // 2
                                        let listItem = ListModel(name: nameText.text!, position: positionText.text!)
                                        // 3
                                        let firstItemRef = self.ref.child(firstText.lowercased())
                                        // 4
                                        firstItemRef.setValue(listItem.toAnyObject())
                                        
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { nameText in
            nameText.placeholder = "Nhập tên"
        }
        alert.addTextField { position in
            position.placeholder = "Nhập vị trí"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
    
}
