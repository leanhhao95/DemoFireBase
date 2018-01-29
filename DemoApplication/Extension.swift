//
//  Extension.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/29/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
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
