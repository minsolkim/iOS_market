//
//  MyFavoriteViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/6/24.
//

import UIKit

class MyFavoriteViewController: UIViewController {
    //테이블 뷰
    private let tableView = UITableView().then {
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
        $0.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
    }
    
}
