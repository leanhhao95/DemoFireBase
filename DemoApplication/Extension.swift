//
//  Extension.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/29/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
import UIKit
let loginToList = "LoginToList"
let listToUsers = "ListToUsers"
extension TimeInterval {
    func gethour() -> String {
        let hour = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        dateFormatter.locale = Locale(identifier: "EN" )
        return dateFormatter.string(from: hour )
    }
    
    func dayWeek() -> String {
        let getDay = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "EN" )
        return dateFormatter.string(from: getDay )
    }
    func convertDay() -> String {
        let getDay = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "yyyyMMddHHmmssSSS" )
        return dateFormatter.string(from: getDay )
    }
}

class View: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        centerVertically()
    }
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}