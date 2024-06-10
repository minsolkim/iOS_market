//
//  NavigationBar.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/5/24.
//

import Foundation
import SnapKit
import Then
import UIKit

final class NavigationBar : UIView {
    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .white
    }
    
    private let homeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_home")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //MARK: -- 컴포넌트 설정
        setUI()
        
        //MARK: -- addSubView
        setHierarchy()
        
        //MARK: -- autolayout 설정
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
}

private extension NavigationBar {
    func setUI() {
        backgroundColor = .clear
        tintColor = .white
    }
    
    func setHierarchy() {
        addSubview(backButton)
        addSubview(homeButton)
    }
    
    func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(97)
        }
        backButton.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(55)
            make.leading.equalToSuperview().inset(8)
            make.size.equalTo(28)
        }
        homeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(55)
            make.leading.equalTo(backButton.snp.trailing).offset(14)
            make.size.equalTo(28)
        }
    }
}


