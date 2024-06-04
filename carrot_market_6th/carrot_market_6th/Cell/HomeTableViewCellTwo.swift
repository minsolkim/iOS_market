//
//  HomeTableViewCellTwo.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/8/24.
//

import UIKit
import Then
import SnapKit

class HomeTableViewCellTwo: UITableViewCell {
    static let id = "HomeTableViewCellTwo"
    static let cellHeight = 240.0
    var itemList: HorizItemList? {
        didSet {
            collectionView.reloadData()
        }
    }
    let label = UILabel().then {
        $0.text = "시원한 여름 간식의 계절🌈"
        $0.font = UIFont.boldSystemFont(ofSize: 19)
        $0.numberOfLines = 0
        $0.textColor = .black
    }
    
    private let button = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: (120), height: 170)
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.id)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setting()
        contentView.addSubview(label)
        contentView.addSubview(button)
        contentView.addSubview(collectionView)
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(15)
        }
        
        button.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(10)
        }
        
    }
    
    func setting() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
}

extension HomeTableViewCellTwo: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList?.items.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.id, for: indexPath) as! HomeCollectionViewCell
        if let item = itemList?.items[indexPath.row] {
            
            cell.imageView.image = item.image
            cell.titleLabel.text = item.title
            cell.priceLabel.text = item.price
        }
        return cell
    }
}
