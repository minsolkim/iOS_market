//
//  HorizItem.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/12/24.
//

import Foundation
import UIKit

struct HorizItem {
    let image: UIImage?
    let title: String
    let price: String
    
    
    init(image: UIImage?, title: String, price: String ) {
        self.image = image
        self.title = title
        self.price = price
    }
    
}
