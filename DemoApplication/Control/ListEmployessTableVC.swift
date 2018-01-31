//
//  ListTableVC.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/25/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase

class ListEmployessTableVC: UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    // MARK: Properties
    var items = [ListModel]()
   
    var userCountBarButtonItem: UIBarButtonItem!
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        observerUser()
        dataService.getInfoUser()
        dataService.observerRef()
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
        registerNotification()
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .sendItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .removeUser , object: nil)
    }
    @objc func reloadData() {
        let currentUserRef = dataService.usersRef.child(dataService.user.uid)
        currentUserRef.removeValue()
        tableView.reloadData()
    }
    @objc func getData() {
        items = dataService.items
        tableView.reloadData()
    }
    
    deinit {
      
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAdmin()
    }
    // MARK: UITableView Delegate DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .displayNextCell:
                return 1
            case .displayDataFBCell:
                return items.count
            }
        } else {
            return 0
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = indexPath.section == Section.displayNextCell.rawValue ? "listCell" : "ItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if indexPath.section == Section.displayNextCell.rawValue {
            if let numberUserCell = cell as? ListEmployeesCell {
                numberUserCell.displayNextLabel.text = "Click Để Vào Phòng Chat"
            }
        } else if indexPath.section == Section.displayDataFBCell.rawValue {
            cell.textLabel?.text = items[indexPath.row].name
            cell.detailTextLabel?.text = items[indexPath.row].position
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items[indexPath.row].ref?.removeValue()
        }
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if DataServices.share.email == "admin@gmail.com" {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkOnline {
                dataService.nameDisplay = dataService.user.email
               self.performSegue(withIdentifier: nextToChannelView, sender: nil)
        }
    }
    
    // MARK: Add Item
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        
                                        let nameText = alert.textFields![0]
                                        let positionText = alert.textFields![1]
                                        guard let firstText = nameText.text, let _ = positionText.text else {return}
                                        let listItem = ListModel(name: nameText.text!, position: positionText.text!)
                                        let firstItemRef = dataService.ref.child(firstText.lowercased())
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
    // MARK: firebase related methods
    // Lấy dữ liệu từ firebase
    
    func observerUser() {
      dataService.usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = "online: \(snapshot.childrenCount.description)"
            } else {
                self.userCountBarButtonItem?.title = "online: 0"
            }
        })
    }
    
    @objc func userCountButtonDidTouch() {
        checkOnline {
              self.performSegue(withIdentifier: listToUsers, sender: nil)
        }
    }
    // Support
    func checkAdmin() {
        if DataServices.share.email == "admin@gmail.com" {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
    func checkOnline(completeHandle: @escaping () -> Void) {
        if userCountBarButtonItem.title == "online: 0" {
            showAlert(vc: self, title: "Chưa đăng nhập", message: "Cần đăng nhập để tham gia phòng chat")
        } else {
            completeHandle()
        }
    }
    func showAlert(vc: UIViewController, title:String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in}
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    enum Section: Int {
        case displayNextCell = 0
        case displayDataFBCell
    }
}

