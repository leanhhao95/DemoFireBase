//
//  CustomCell.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/26/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var displayName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
class LocalCell: CustomCell {
    
}
class UnownedCell: CustomCell {
    
}
