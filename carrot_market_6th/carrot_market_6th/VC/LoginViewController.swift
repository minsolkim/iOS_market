//
//  LoginViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/6/24.
//

import UIKit
import SnapKit
import Then
import FirebaseAuth
import FirebaseFirestore
class LoginViewController: UIViewController {
    private let nicknameLabel = UILabel()
    private let nicknameTextField = UITextField()
    private let passwordLabel = UILabel()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton()
    private let joinButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConfigure()
        setConstraints()
        setupActions()
    }
    
    func setConfigure() {
        nicknameLabel.do {
            $0.text = "닉네임"
            $0.font = .boldSystemFont(ofSize: 13)
            $0.textColor = .black
        }
        nicknameTextField.do {
            $0.backgroundColor = UIColor.warmgray2
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textColor = .black
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: $0.frame.height))
            $0.leftView = leftPaddingView
            $0.leftViewMode = .always
        }
        passwordLabel.do {
            $0.text = "비밀번호"
            $0.font = .boldSystemFont(ofSize: 13)
            $0.textColor = .black
        }
        
        passwordTextField.do {
            $0.backgroundColor = UIColor.warmgray2
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.textColor = .black
            $0.clearButtonMode = .whileEditing
            $0.isSecureTextEntry = true
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: $0.frame.height))
            $0.leftView = leftPaddingView
            $0.leftViewMode = .always
        }
        joinButton.do {
            $0.backgroundColor = UIColor.warmgray
            $0.setTitle("회원가입", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        loginButton.do {
            $0.backgroundColor = UIColor.orange
            $0.setTitle("로그인", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
    }
    
    func setConstraints() {
        view.addSubviews(nicknameLabel, nicknameTextField, passwordLabel, passwordTextField, joinButton,loginButton)
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.left.equalToSuperview().offset(20)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        joinButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(joinButton.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
    }
    
    func setupActions() {
        joinButton.addTarget(self, action: #selector(joinButtonTapped(_:)), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTaaped(_:)), for: .touchUpInside)
    }
    
    @objc private func joinButtonTapped(_ sender: Any) {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("오류", "닉네임과 비밀번호를 모두 입력하세요.")
            return
        }
        
        // 닉네임을 이메일 형식으로 변환
        let email = "\(nickname)@naver.com"
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert("오류", error.localizedDescription)
                return
            }
            
            // 회원가입 후 닉네임을 Firestore에 저장
            if let user = authResult?.user {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "nickname": nickname
                ]) { error in
                    if let error = error {
                        self.showAlert("오류", error.localizedDescription)
                        return
                    }
                    // 홈 화면으로 이동
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.showMainTabBarController()
                    }
                }
            }
        }
    }
    @objc private func loginButtonTaaped(_ sender: Any) {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("오류", "이메일과 비밀번호를 모두 입력하세요.")
            return
        }
        let email = "\(nickname)@naver.com"
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert("오류", error.localizedDescription)
                return
            }
            
            // 로그인 성공 후 홈 화면으로 이동
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showMainTabBarController()
            }
        }
    }

    
    private func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}


