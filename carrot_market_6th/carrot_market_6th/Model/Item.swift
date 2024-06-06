//
//  Item.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/9/24.
//

import Foundation
import UIKit

struct Item {
    let id: String
    let nickname: String
    let image: UIImage?
    let title: String
    let description: String
    let price: String?
    let date: String?
    let heartIcon: UIImage?
    let heartNumber: String?
    
    init(id: String,nickname: String,image: UIImage?, title: String, description: String, price: String?, date: String?,heartIcon: UIImage?, heartNumber: String? ) {
        self.id = id
        self.nickname = nickname
        self.image = image
        self.title = title
        self.description = description
        self.price = price
        self.date = date
        self.heartIcon = heartIcon
        self.heartNumber = heartNumber
    }
    
}
