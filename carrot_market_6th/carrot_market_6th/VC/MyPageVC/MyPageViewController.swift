//
//  FifthViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/7/24.
//

import UIKit
import SnapKit
import Then
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MyPageViewController: UIViewController {
    let profileImage = UIImageView()
    let profileName = UILabel()
    let myChangeLabel = UILabel()
    let favoriteMeBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setConfig()
        fetchNickname()
    }
    
    private func setUI() {
        profileImage.do {
            $0.image = UIImage(named: "profile")
        }
        profileName.do {
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 25)
        }
        myChangeLabel.do {
            $0.text = "나의 거래"
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 16)
        }
        favoriteMeBtn.do {
            $0.setImage(UIImage(systemName: "heart"), for: .normal)
            $0.tintColor = .black
            $0.setTitle("관심 목록", for: .normal)
            $0.semanticContentAttribute = .forceLeftToRight
            $0.contentHorizontalAlignment = .left
            $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            $0.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        }
    }
    private func setConfig() {
        view.addSubviews(profileImage,profileName,myChangeLabel,favoriteMeBtn)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(60)
        }
        profileName.snp.makeConstraints { make in
            make.centerY.equalTo(profileImage.snp.centerY)
            make.leading.equalTo(profileImage.snp.trailing).offset(20)
            
        }
        myChangeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(40)
            make.leading.equalTo(profileImage.snp.leading)
            
        }
        favoriteMeBtn.snp.makeConstraints { make in
            make.top.equalTo(myChangeLabel.snp.bottom).offset(20)
            make.leading.equalTo(myChangeLabel.snp.leading)
            make.width.equalTo(100)
        }
    }
    private func fetchNickname() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                self.profileName.text = data["nickname"] as? String
            } else {
                self.showAlert("Error", error?.localizedDescription ?? "Failed to fetch nickname.")
            }
        }
    }
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    //나의 관심내역
    @objc func favoriteTapped() {
        let myFavoriteList = MyFavoriteViewController()
        navigationController?.pushViewController(myFavoriteList, animated: true)
    }

}
