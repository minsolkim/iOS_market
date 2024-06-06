//
//  PurchaseView.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/5/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import FirebaseFirestore

final class PurchaseView : UIView {
    var item: Item?
    private let seperatedView = SeperatedView(height: 1)
    let addCartButton = UIButton()
    let heartButton = UIButton()
    let priceLabel = UILabel()
    let verticalView = UIView()
    let priceInfoLabel = UILabel()
    private var isHeartSelected = false
    private var heartCount: Int = 0
    init() {
        super.init(frame: .zero)
            setUI()
            
            setHierarchy()
            
            setLayout()
        
            setTarget()
        
        }
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
}
private extension PurchaseView {
    func setUI() {
        backgroundColor = .white
        heartButton.do {
            $0.setImage(UIImage.init(named: "heart"), for: .normal)
            $0.tintColor = .gray
        }
        addCartButton.do {
            $0.setTitle("구매하기", for: .normal)
            $0.backgroundColor = .orange
            $0.titleLabel?.font = .boldSystemFont(ofSize: 17)
            $0.layer.cornerRadius = 13
        }
        priceLabel.do {
            $0.text = "20,000원"
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 16)
        }
        priceInfoLabel.do {
            $0.text = "가격 제안 불가"
            $0.textColor = .warmgray
            $0.font = .boldSystemFont(ofSize: 14)
        }
        verticalView.do {
            $0.backgroundColor = .warmgray2
        }
    }
    
    func setHierarchy() {
        addSubviews(seperatedView,heartButton,addCartButton,verticalView,priceLabel,priceInfoLabel)
        
    }
    
    func setLayout() {
        seperatedView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        heartButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.width.height.equalTo(60)
        }
        addCartButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.width.equalTo(100)
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(15)
            
        }
        verticalView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.leading.equalTo(heartButton.snp.trailing)
            make.top.bottom.equalToSuperview().inset(15)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(verticalView.snp.trailing).offset(8)
            make.top.equalTo(verticalView.snp.top).offset(10)
            make.width.equalTo(130)
        }
        
        priceInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.leading)
            make.top.equalTo(priceLabel.snp.bottom)
            
        }
        
    }
    
    func setTarget() {
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
    }
    
    @objc private func heartButtonTapped() {
        isHeartSelected.toggle()
        let imageName = isHeartSelected ? "fillHeart" : "heart"
        heartButton.setImage(UIImage(named: imageName), for: .normal)
        updateHeartCount(increment: isHeartSelected)

    }
    
    private func updateHeartCount(increment: Bool) {
        guard let itemID = item?.id else { return }
        let db = Firestore.firestore()
        let incrementValue = increment ? 1 : -1
        db.collection("posts").document(itemID).updateData([
            "heartCount": FieldValue.increment(Int64(incrementValue))
        ]) { error in
            if let error = error {
                print("Error updating heart count: \(error)")
            } else {
                print("Heart count updated successfully")
                self.heartCount += incrementValue
            }
        }
    }
}
