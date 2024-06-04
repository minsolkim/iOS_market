//
//  ItemList.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/9/24.
//

import Foundation
import UIKit

struct ItemList {
    
    let items: [Item]
    init() {
        let item1 = Item(image: UIImage(named: "tab1"), title: "[급구] 50만원 제공! 쿵야 레스토랑에서 시식 알바 구합니다.^^~", description: "당근알바 . 이벤트", price: nil, date: nil, chatIcon: nil, chatNumber: nil, heartIcon: nil, heartNumber: nil)
        let item2 = Item(image: UIImage(named: "tab2"), title: "에어팟맥스실버", description: "서울특별시 양천구", price: "370,000원", date: "6일전", chatIcon: UIImage(named: "chatIcon"), chatNumber: "5", heartIcon: UIImage(named: "heartIcon"), heartNumber: "23")
        let item3 = Item(image: UIImage(named: "tab3"), title: "에어팟 맥스 스페이스그레이 S급 판매합니다.", description: "서울특별시 양천구", price: "490,000원", date: "3시간 전", chatIcon: UIImage(named: "chatIcon"), chatNumber: "1", heartIcon: UIImage(named: "heartIcon"), heartNumber: "4")
        let item4 = Item(image: UIImage(named: "tab4"), title: "[S급]에어팟 맥스 스페이스 그레이 풀박 판매합니다.", description: "서울특별시 양천구", price: "650,000원", date: "1일 전", chatIcon: UIImage(named: "chatIcon"), chatNumber: "1", heartIcon: UIImage(named: "heartIcon"), heartNumber: "7")
        self.items = [item1,item2,item3,item4]
    }
    
}
