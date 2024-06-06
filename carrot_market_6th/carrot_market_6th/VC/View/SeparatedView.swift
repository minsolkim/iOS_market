//
//  SeparatedView.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/5/24.
//

import UIKit
import SnapKit
import Then

final class SeperatedView: UIView {
    init(height: CGFloat) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.warmgray
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

