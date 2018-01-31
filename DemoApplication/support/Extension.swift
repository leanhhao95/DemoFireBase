//
//  Extension.swift
//  DemoApplication
//
//  Created by Anh Hao on 1/29/18.
//  Copyright © 2018 Anh Hao. All rights reserved.
//

import Foundation
import UIKit
// name segue
let nextToChannelView = "nextToChannelView"
let loginToList = "LoginToList"
let listToUsers = "ListToUsers"
// name service
let dataService = DataServices.share
let messageService = MesssageService.shared
extension Notification.Name {
    static let sendItem = Notification.Name.init("sendItem")
    static let removeUser = Notification.Name.init("removeUser")
    static let itemMessage = Notification.Name.init("itemMessage")
}
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
//class DemoGeneric {
//    var a = 5
//    var b = 6
//    func swapToIndex<T>( firstIndex:inout T, secondIndex:inout T) {
//        let temporaryA = firstIndex
//        firstIndex = secondIndex
//        secondIndex = temporaryA
//    }
//    func swap() {
//        swapToIndex(firstIndex: &a, secondIndex: &b)
//    }
//}
//protocol VCInNavigation {
//    
//    var numberVCInNav: Int? { get }
//    
//    func delegateSwipeBack(of viewController: UIViewController?, to delegate: UIViewController?)
//    
//    func enableSwipeBack(enable: Bool, for viewController: UIViewController?)
//    
//    func viewWillSwipeBack()
//}

