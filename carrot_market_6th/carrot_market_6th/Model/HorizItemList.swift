//
//  HorizItemList.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/12/24.
//

import Foundation
import UIKit

struct HorizItemList {
    
    let items: [HorizItem]
    init() {
        let item1 = HorizItem(image: UIImage(named: "image1"), title: "키친플라워 DW1201CP", price: "62,000원")
        
        let item2 = HorizItem(image: UIImage(named: "image2"), title: "얼음 트레이 소 (얼음판)/개당 판매", price: "1,000원")
       
        let item3 = HorizItem(image: UIImage(named: "image3"), title: "실리콘 얼음틀", price: "2,000원")
        
        let item4 = HorizItem(image: UIImage(named: "image4"), title: "밥바바", price: "5,000원")
        self.items = [item1,item2,item3,item4]
        
    }
}
