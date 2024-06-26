//
//  FirstViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/7/24.
//

import UIKit
import SnapKit
import Then
import FirebaseFirestore

class HomeViewController: UIViewController,ItemDetailViewControllerDelegate {
    deinit {
        NotificationCenter.default.removeObserver(self, name: .statusDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .heartCountDidChange, object: nil)
    }
    //MARK: -- Property
    let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
    }
    var totalItems: [Item] = []
    private let tableView = UITableView().then {
        $0.allowsSelection = true
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
    
    private let floatingButton =  UIButton().then {
        $0.backgroundColor = .systemOrange
        $0.tintColor = .white
        $0.setTitle("+글쓰기", for: .normal) // 버튼의 타이틀 설정
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.3
        $0.isHidden = false
        $0.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationController()
        setTableView()
        addSubviews()
        setConfig()
        loadData() // Firestore 데이터 로드
        NotificationCenter.default.addObserver(self, selector: #selector(handleStatusDidChange(_:)), name: .statusDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHeartCountDidChange(_:)), name: .heartCountDidChange, object: nil)
        
    }
    private func addSubviews() {
        view.addSubviews(tableView,floatingButton,activityIndicator)
        view.bringSubviewToFront(floatingButton)
        floatingButton.isHidden = false
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    private func setConfig() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
        titleLabel.text = "우체통마켓"
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        let image2 = UIImage(named: "loupe")?.resizeImage(targetSize: CGSize(width: 25, height: 25))
        let searchBtn = UIBarButtonItem(image: image2?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(searchTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        flexibleSpace.width = 5.0
        navigationItem.rightBarButtonItems = [searchBtn, flexibleSpace]
    }
    
    func didDeleteItem(_ item: Item) {
        if let index = totalItems.firstIndex(where: { $0.id == item.id }) {
            totalItems.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func setTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // Firestore 데이터 로드
    private func loadData() {
        activityIndicator.startAnimating()
        let db = Firestore.firestore()
        
        db.collection("posts")
            .order(by: "timestamp", descending: true) // timestamp 기준으로 내림차순 정렬
            .getDocuments { snapshot, error in
                if let error = error {
                    print("오류: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents")
                    self.activityIndicator.stopAnimating()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                var items: [Item] = []
                
                for document in documents {
                    let documentId = document.documentID
                    let heartCount = document.data()["heartCount"] as? Int ?? 0
                    let isCompleted = document.data()["isCompleted"] as? Bool ?? false
                    guard let nickname = document.data()["nickname"] as? String,
                          let title = document.data()["title"] as? String,
                          let price = document.data()["price"] as? String,
                          let content = document.data()["content"] as? String,
                          let timestamp = document.data()["timestamp"] as? Timestamp,
                          let imageUrls = document.data()["imageUrls"] as? [String],
                          let imageUrlString = imageUrls.first,
                          let imageUrl = URL(string: imageUrlString)
                    else {
                        continue
                    }
                    
                    dispatchGroup.enter()
                    
                    // 비동기적으로 이미지를 다운로드합니다.
                    self.downloadImage(from: imageUrl) { image in
                        let formattedPrice = self.formatPrice(price)
                        let relativeDate = self.relativeDateString(for: timestamp.dateValue())
                        
                        let item = Item(id: documentId, nickname: nickname, image: image, title: title, description: content, price: formattedPrice, date: relativeDate, heartIcon: UIImage(named: "heartIcon"), heartNumber: "\(heartCount)", isCompleted: isCompleted)
                        items.append(item)
                        
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.totalItems = items
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
    }

    
    // 이미지를 다운로드하는 함수
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    //가격 포맷 함수
    private func formatPrice(_ price: String) -> String {
        let formattedPrice = price.dropFirst()
        return "\(formattedPrice) 원"
    }
    // 상대적 시간 포맷 함수
    private func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
    // 플로팅 버튼을 눌렀을 때 실행될 액션
    @objc func floatingButtonTapped() {
        // ItemAddViewController 인스턴스 생성
        let itemAddViewController = ItemAddViewController()
        itemAddViewController.delegate = self // delegate 설정
        // UINavigationController로 래핑
        let navigationController = UINavigationController(rootViewController: itemAddViewController)
        // 모달 프레젠테이션 스타일을 전체 화면으로 설정
        navigationController.modalPresentationStyle = .fullScreen
        // 뷰 컨트롤러를 모달로 프레젠트
        self.present(navigationController, animated: true, completion: nil)
    }

}

extension HomeViewController: ItemAddViewControllerDelegate {
    func didSaveNewItem() {
        loadData()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id, for: indexPath) as! HomeTableViewCell
            let item = totalItems[indexPath.row]
            cell.selectionStyle = .none
            cell.titleLabel.text = item.title
            cell.priceLabel.text = item.price
            cell.dateLabel.text = item.date
            cell.isCompleted = item.isCompleted
            if let heartNumber = item.heartNumber, let heartCount = Int(heartNumber), heartCount > 0 {
                cell.heartNumberLabel.text = heartNumber
                cell.heartNumberLabel.isHidden = false
            } else {
                cell.heartNumberLabel.text = nil
                cell.heartNumberLabel.isHidden = true
            }
            cell.heartIcon.image = item.heartIcon
            cell.thumbnailImageView.image = item.image
            
            return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = totalItems[indexPath.row]

            let detailVC = ItemDetailViewController(item: item)
            detailVC.item = item
            navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    //MARK: -- Action
    
    @objc func searchTapped() {
        print("검색창 넘어가기")
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func handleHeartCountDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let itemId = userInfo["itemId"] as? String,
              let heartCount = userInfo["heartCount"] as? Int else { return }
        if let index = totalItems.firstIndex(where: { $0.id == itemId }) {
            if var item = totalItems[index] as? Item {
                let currentHeartCount = Int(item.heartNumber ?? "0") ?? 0
                item.heartNumber = "\(currentHeartCount + heartCount)"
                totalItems[index] = item
                
                // Reload the corresponding row in tableView
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }


    
    @objc private func handleStatusDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let itemId = userInfo["itemId"] as? String,
              let isCompleted = userInfo["isCompleted"] as? Bool else { return }
        
        if let index = totalItems.firstIndex(where: { $0.id == itemId }) {
            if var item = totalItems[index] as? Item {
                item.isCompleted = isCompleted
                totalItems[index] = item
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
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


