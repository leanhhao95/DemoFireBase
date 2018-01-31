//
//  ChatTableView.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/25/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase
class OnlineTableView: UITableViewController {
    
    // MARK: Constants
    let userCell = "UserCell"
    let usersRef = Database.database().reference(withPath: "online")
    let channelRef = Database.database().reference().child("channels")
    // MARK: Properties
    var currentUsers: [String] = []
    var key: [String] = []
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersRef.observe(.childAdded, with: { snap in
            guard let email = snap.value as? String else { return }
            self.key.append(snap.key)
            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
        })
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.key.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if currentUsers[indexPath.row] == dataService.email {
            cell?.isUserInteractionEnabled = false
            cell?.accessoryType = .detailDisclosureButton
            tableView.reloadData()
        } else {
            performSegue(withIdentifier: "privateRoom", sender: nil)
            dataService.nameDisplay = currentUsers[indexPath.row]
            if messageService.channelRef == nil {
                messageService.channelRef = channelRef.child("\(dataService.senderID)\(self.key[indexPath.row])")
                print(messageService.channelRef)
            }
            if messageService.messages == nil {
                messageService.channelRef = channelRef.child("\(self.key[indexPath.row])\(dataService.senderID)")
                 print(messageService.channelRef)
            } 
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
    
    // MARK: Actions
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
        dataService.signOut {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "privateRoom":
            if let chatVc = segue.destination as? MessageViewController {
                chatVc.channel = Channel(id: "1", name: "privateRoom")
                chatVc.senderDisplayName = dataService.email
                chatVc.senderId = DataServices.share.senderID
            }
        default:
            return
        }
    }
    
}
