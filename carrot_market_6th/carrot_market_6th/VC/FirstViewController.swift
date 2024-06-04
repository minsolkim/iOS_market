//
//  FirstViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/7/24.
//

import UIKit
import SnapKit
import Then

class FirstViewController: UIViewController {
    //MARK: -- Property
    let itemList = ItemList()
    let collectItemList = HorizItemList()
    var totalItems: [TotalItem] = []
    private let tableView = UITableView().then {
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
        $0.register(HomeTableViewCellTwo.self, forCellReuseIdentifier: HomeTableViewCellTwo.id)
    }
    
    private let floatingButton =  UIButton().then {
        $0.backgroundColor = .systemOrange
        $0.tintColor = .white
        $0.setTitle("+글쓰기", for: .normal) // 버튼의 타이틀 설정
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 25 // 모서리를 둥글게 하는 정도 조절
        $0.clipsToBounds = true
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.3
        $0.isHidden = false
        $0.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        totalItems = createTotalItems()
        setNavigationController()
        setTableView()
        addSubviews()
        setConfig()
        
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        view.bringSubviewToFront(floatingButton)
        floatingButton.isHidden = false
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    private func setConfig() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        floatingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.equalTo(100)
            $0.height.equalTo(57)
        }
    }
    private func setNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let titleLabel = UILabel()
        titleLabel.text = "내 위치"
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        let image1 = UIImage(named: "bell")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
        let image2 = UIImage(named: "loupe")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
        let button1 = UIBarButtonItem(image: image1?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(button1Tapped))
        let button2 = UIBarButtonItem(image: image2?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(button2Tapped))
        
        // 간격을 설정할 UIBarButtonItem을 생성합니다.
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        flexibleSpace.width = 5.0 // 간격 너비 조정
        
        // 오른쪽 버튼들과 간격을 배열로 설정합니다.
        navigationItem.rightBarButtonItems = [button1, flexibleSpace, button2, flexibleSpace]
    }
    private func setTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    // 플로팅 버튼을 눌렀을 때 실행될 액션
    @objc func floatingButtonTapped() {
        // ItemAddViewController 인스턴스 생성
        let itemAddViewController = ItemAddViewController()

        // UINavigationController로 래핑
        let navigationController = UINavigationController(rootViewController: itemAddViewController)

        // 모달 프레젠테이션 스타일을 전체 화면으로 설정
        navigationController.modalPresentationStyle = .fullScreen

        // 뷰 컨트롤러를 모달로 프레젠트
        self.present(navigationController, animated: true, completion: nil)
    }
    func createTotalItems() -> [TotalItem] {
        var totalItems: [TotalItem] = []
        
        for item in itemList.items.prefix(3) {
            totalItems.append(.item(item))
        }
        
        if let firstHorizItem = collectItemList.items.first {
            totalItems.append(.horizItem(firstHorizItem))
        }
        
        for item in itemList.items.dropFirst(3) {
            totalItems.append(.item(item))
        }
        return totalItems
    }
    
}

extension FirstViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentItem = totalItems[indexPath.row]
        switch currentItem {
        case .item(_):
            return UITableView.automaticDimension
        case .horizItem(_):
            return HomeTableViewCellTwo.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch totalItems[indexPath.row] {
        case let .item(item):
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id, for: indexPath) as! HomeTableViewCell
            
            cell.titleLabel.text = item.title
            cell.descriptionLabel.text = item.description
            cell.priceLabel.text = item.price
            cell.dateLabel.text = item.date
            cell.chatNumberLabel.text = item.chatNumber
            cell.heartNumberLabel.text = item.heartNumber
            // 채팅 아이콘과 하트 아이콘 설정
            if indexPath.row != 0 {
                cell.chatIcon.image = item.chatIcon
                cell.heartIcon.image = item.heartIcon
            } else {
                cell.chatIcon.image = nil
                cell.heartIcon.image = nil
            }
            
            cell.thumbnailImageView.image = item.image
            
            return cell
        case .horizItem(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCellTwo.id, for: indexPath) as! HomeTableViewCellTwo
            cell.itemList = collectItemList // collectItemList를 설정
            
            return cell
        }
    }
    
    
    //MARK: -- Action
    @objc func button1Tapped() {
        print("Button 1 tapped")
    }
    
    @objc func button2Tapped() {
        
        print("Button 2 tapped")
    }
    
}
extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
