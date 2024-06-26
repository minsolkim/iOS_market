//
//  HomeTableViewCell.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/7/24.
//

import UIKit
import Then
import SnapKit
import Firebase
import FirebaseFirestore

class HomeTableViewCell: UITableViewCell {
    static let id = "HomeTableViewCell"
    
    let thumbnailImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    let finishLabel = PaddedLabel().then {
        $0.font = .boldSystemFont(ofSize: 12)
        $0.layer.backgroundColor = UIColor.darkGray.cgColor
        $0.textColor = .white
        $0.layer.cornerRadius = 7
        $0.layer.masksToBounds = true
        $0.text = "거래완료"
    }
    
    let priceLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.numberOfLines = 0
    }
    
    let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }
    let horizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.spacing = 5
    }
    
    let heartIcon = UIImageView().then {
        $0.image = UIImage(named: "heartIcon")
        
    }
    
    let heartNumberLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = UIColor.warmgray
        $0.numberOfLines = 0
    }
    
    var isCompleted: Bool = false {
        didSet {
            updateUI()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 140)
        ])
        setupUI()
    }
    private func setupUI() {
        
        contentView.addSubviews(finishLabel, thumbnailImageView, titleLabel, dateLabel, priceLabel, heartIcon, heartNumberLabel)
        
        thumbnailImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
            $0.width.equalTo(120)
            $0.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel.snp.leading)
        }
        
        heartIcon.snp.makeConstraints {
            $0.width.height.equalTo(15)
            $0.trailing.equalTo(heartNumberLabel.snp.leading).inset(-10)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        heartNumberLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.centerY.equalTo(heartIcon.snp.centerY)
            $0.width.equalTo(25)
        }
        
        updateUI()
    }
    
    private func updateUI() {
        if isCompleted {
            finishLabel.isHidden = false
            priceLabel.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(5)
                $0.leading.equalTo(finishLabel.snp.trailing).offset(5)
            }
            finishLabel.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(5)
                $0.leading.equalTo(dateLabel.snp.leading)
            }
        } else {
            finishLabel.isHidden = true
            priceLabel.snp.remakeConstraints {
                $0.top.equalTo(dateLabel.snp.bottom).offset(5)
                $0.leading.equalTo(dateLabel.snp.leading)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
