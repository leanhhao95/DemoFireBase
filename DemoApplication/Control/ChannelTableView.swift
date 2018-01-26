//
//  ChannelTableView.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/26/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit
import Firebase
typealias Dict = Dictionary<String, AnyObject>
enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}
class ChannelTableView: UITableViewController {
    var senderDisplayName: String? // 1 tên của người gửi
   var newChannelTextField: UITextField? // 2 tạo 1 tf để thêm 1 kênh mới
    private var channels: [Channel] = [] // 3 tạo 1 mảng chứa các kênh
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels") // 4 lưu trữ một tham chiếu đến các kênh trong database trên fb
    private var channelRefHandle: DatabaseHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        observeChannels()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.senderDisplayName = DataServices.share.nameDisplay
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }

    // MARK: - Table view data source
    // cài đặt số sections, section 1 để thêm 1 channel , section 2 để hiển thị số channel
    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let curentSection: Section = Section(rawValue: section) {
            switch curentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) 
        if indexPath.section == Section.createNewChannelSection.rawValue {
            if let channelCell = cell as? ChannelCell {
           newChannelTextField = channelCell.newChannelTextField
            }
        } else if indexPath.section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[indexPath.row].name
        }
       

        return cell
    }
    // MARK: UITableviewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[indexPath.row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
    // MARK: Action
    @IBAction func createChannelButton(_ sender: Any) {
        if let name = newChannelTextField?.text { // check có tên kênh chưa
            let newChannelRef = channelRef.childByAutoId() // tạo một tham chiếu đến kênh mới bằng key childByAutoId
            let channelItem = [
                "name": name
            ]  // tạo một dict để giữ dữ liệu cho kênh này
            newChannelRef.setValue(channelItem)
            // đặt tên cho kênh mới và tự động lưu vào database trên fb
        }
    }
    
    
    // MARK: firebase related methods
    private func observeChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) in
            //1:  xử lý 1 reference đến kênh, complete block mỗi khi có 1 kênh mới được thêm vào database trên fb
            let channelData = snapshot.value as! Dict
            //2: hoàn thành nhận dữ liệu DataSnapshot( được chứa trong snapshot(chứa data và các phương thức hỗ trợ ))
            let id = snapshot.key
            if let name = channelData["name"] as? String, name.characters.count > 0 {
                // lấy dữ liệu từ snapshot và thêm nó vào mảng kênh
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("error!")
            }
        })
    }
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
            chatVc.senderId = DataServices.share.senderID
        }
    }
    

}
