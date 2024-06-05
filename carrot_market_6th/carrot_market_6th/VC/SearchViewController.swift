//
//  SearchViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/5/24.
//

import UIKit
import SnapKit
import Then

class SearchViewController: UIViewController {
    let searchTextField = UITextField()
    let clearButton = UIButton(type: .custom)
    let backButton = UIButton(type: .custom)
    private let tableView = UITableView().then {
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
    // ViewController가 해제될 때
    deinit {
        navigationController?.setNavigationBarHidden(false, animated: false) // 네비게이션 바 다시 보이게 설정
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false) // 네비게이션 바 숨김
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConfigure()
        setConstraints()
    }
    
    func setConfigure() {
        searchTextField.do {
            $0.backgroundColor = UIColor.warmgray2 // 검색창 배경색 설정
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.placeholder = "신림동 근처에서 검색" // 플레이스홀더 설정
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: searchTextField.frame.height)) // 왼쪽 여백 설정
            $0.leftViewMode = .always // 항상 왼쪽에 뷰 표시
        }
        
        clearButton.do {
            $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal) // 이미지 설정
            $0.tintColor = UIColor.systemGray2 // 버튼 색상 설정
            $0.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside) // 버튼 탭 액션 설정
        }
        backButton.do {
            $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        
    }
    @objc func clearButtonTapped() {
        searchTextField.text = "" // 검색창 텍스트 삭제
    }
    // 뒤로 가기 버튼을 눌렀을 때
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    func setConstraints() {
        // 수평 스택 뷰 생성
        let horizontalStackView = UIStackView(arrangedSubviews: [backButton, searchTextField])
        horizontalStackView.spacing = 8
        
        // 전체 뷰에 수평 스택 뷰 추가
        view.addSubview(horizontalStackView)
        view.addSubview(tableView)
        // 수평 스택 뷰의 제약 조건 설정
        horizontalStackView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // 검색창 내에 삭제 버튼 위치 조정
        searchTextField.addSubview(clearButton)
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
        
//        tableView.snp.makeConstraints {
//            
//        }
    }
    
    
}
