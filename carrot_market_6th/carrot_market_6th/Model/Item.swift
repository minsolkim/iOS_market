//
//  Item.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/9/24.
//

import Foundation
import UIKit

struct Item {
    
    let image: UIImage?
    let title: String
    let description: String
    let price: String?
    let date: String?
    let chatIcon: UIImage?
    let chatNumber: String?
    let heartIcon: UIImage?
    let heartNumber: String?
    
    init(image: UIImage?, title: String, description: String, price: String?, date: String?, chatIcon: UIImage?, chatNumber: String?, heartIcon: UIImage?, heartNumber: String? ) {
        self.image = image
        self.title = title
        self.description = description
        self.price = price
        self.date = date
        self.chatIcon = chatIcon
        self.chatNumber = chatNumber
        self.heartIcon = heartIcon
        self.heartNumber = heartNumber
    }
    
}
