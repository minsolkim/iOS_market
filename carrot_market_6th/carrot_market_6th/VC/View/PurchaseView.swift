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
import FirebaseAuth

final class PurchaseView: UIView {
    var itemId: String?
    private let seperatedView = SeperatedView(height: 1)
    let addCartButton = UIButton()
    let heartButton = UIButton()
    let priceLabel = UILabel()
    let verticalView = UIView()
    let priceInfoLabel = UILabel()
    private var isHeartSelected = false
    private var heartCount: Int = 0
    
    init(itemId: String?) {
        self.itemId = itemId
        super.init(frame: .zero)
        setUI()
        setHierarchy()
        setLayout()
        setTarget()
        checkHeartStatus()
        checkIsCompleted()
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
            $0.setImage(UIImage(named: "heart"), for: .normal)
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
        addSubviews(seperatedView, heartButton, addCartButton, verticalView, priceLabel, priceInfoLabel)
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
            make.centerY.equalToSuperview()
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
        addCartButton.addTarget(self, action: #selector(addCartButtonTapped), for: .touchUpInside)
        
    }
    
    @objc private func heartButtonTapped() {
        isHeartSelected.toggle()
        let imageName = isHeartSelected ? "fillHeart" : "heart"
        heartButton.setImage(UIImage(named: imageName), for: .normal)
        updateHeartStatus(increment: isHeartSelected)
    }
    
    @objc private func addCartButtonTapped() {
        handlePurchase()
    }
    
    private func handlePurchase() {
        guard let itemID = itemId else {
            print("Item ID is nil.")
            return
        }
        let db = Firestore.firestore()
        
        db.collection("posts").document(itemID).updateData([
            "isCompleted": true
        ]) { error in
            if let error = error {
                print("Error updating isCompleted status: \(error)")
            } else {
                print("isCompleted status updated successfully")
                NotificationCenter.default.post(name: .statusDidChange, object: nil, userInfo: ["itemId": itemID, "isCompleted": true])
                self.addCartButton.isEnabled = false
                self.addCartButton.backgroundColor = .gray
                self.presentPurchaseCompleteAlert()
            }
        }
    }
    
    private func updateHeartCount(increment: Bool) {
        guard let itemID = itemId else { return }
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
                NotificationCenter.default.post(name: .heartCountDidChange, object: nil, userInfo: ["itemId": self.itemId, "heartCount": self.heartCount])
                
            }
        }
    }
    
    private func updateHeartStatus(increment: Bool) {
        guard let itemID = itemId else {
            print("Item ID is nil.")
            return
        }
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User ID is nil.")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("posts").document(itemID).collection("hearts").document(userID)
        let userHeartRef = db.collection("users").document(userID)
        if increment {
            userRef.setData([:]) { error in
                if let error = error {
                    print("Error adding heart: \(error.localizedDescription)")
                } else {
                    print("Heart added successfully")
                    self.updateHeartCount(increment: true)
                    
                    userHeartRef.updateData([
                        "heartPost": FieldValue.arrayUnion([itemID])
                    ])
                }
            }
        } else {
            userRef.delete { error in
                 if let error = error {
                     print("Error removing heart: \(error.localizedDescription)")
                 } else {
                     print("Heart removed successfully")
                     self.updateHeartCount(increment: false)
                     // Remove post ID from heartPost array in user's document
                     userHeartRef.updateData([
                         "heartPost": FieldValue.arrayRemove([itemID])
                     ]) { error in
                         if let error = error {
                             print("Error removing post ID from heartPost: \(error.localizedDescription)")
                         } else {
                             print("Post ID removed from heartPost successfully")
                         }
                     }
                 }
             }
        }
    }
    
    private func presentPurchaseCompleteAlert() {
        guard let viewController = self.window?.rootViewController else { return }
        
        let alert = UIAlertController(title: "구매 완료", message: "구매가 완료되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    private func checkIsCompleted() {
        guard let itemID = itemId else { return }
        let db = Firestore.firestore()
        
        db.collection("posts").document(itemID).getDocument { document, error in
            if let document = document, document.exists {
                if let isCompleted = document.data()?["isCompleted"] as? Bool {
                    self.addCartButton.isEnabled = !isCompleted
                    self.addCartButton.backgroundColor = isCompleted ? .gray : .orange
                }
            } else {
                print("Document does not exist or error occurred: \(String(describing: error))")
            }
        }
    }
    
    private func checkHeartStatus() {
        guard let itemID = itemId else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("posts").document(itemID).collection("hearts").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.isHeartSelected = true
                self.heartButton.setImage(UIImage(named: "fillHeart"), for: .normal)
            } else {
                self.isHeartSelected = false
                self.heartButton.setImage(UIImage(named: "heart"), for: .normal)
            }
        }
    }
}
extension Notification.Name {
    static let heartCountDidChange = Notification.Name("heartCountDidChange")
}
