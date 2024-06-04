//
//  HomeCollectionViewCell.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/8/24.
//

import UIKit
import SnapKit
import Then

class HomeCollectionViewCell: UICollectionViewCell {
    static let id = "HomeCollectionViewCell"
    
    let imageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 12)
    }
    
    let priceLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 13)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        
        imageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.height.equalTo(110)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(imageView)
            
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
