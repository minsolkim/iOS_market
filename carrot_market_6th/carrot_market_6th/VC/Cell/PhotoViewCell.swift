//
//  PhotoViewCell.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/3/24.
//

import UIKit
import SnapKit
import Then
import SnapKit

class PhotoViewCell: UICollectionViewCell {
    static let identifier = "PhotoCell"
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setConfigure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set UI
    private func setConfigure() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
    }
    
    private func setConstraints() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.bottom.equalTo(contentView.snp.bottom)
        }
    }
}

