//
//  SearchViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/5/24.
//

import UIKit
import SnapKit
import Then
import FirebaseFirestore

class SearchViewController: UIViewController {
    let searchTextField = UITextField()
    let clearButton = UIButton(type: .custom)
    let backButton = UIButton(type: .custom)
    private var allItems: [Item] = []
    private var filteredItems: [Item] = []
    private let tableView = UITableView().then {
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
        $0.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConfigure()
        setConstraints()
        setupTableView()
        loadData()
    }
    
    func setConfigure() {
        searchTextField.do {
            $0.backgroundColor = UIColor.warmgray2
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.placeholder = "내 근처에서 검색"
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: searchTextField.frame.height))
            $0.leftViewMode = .always
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        clearButton.do {
            $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            $0.tintColor = UIColor.systemGray2
            $0.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        }
        backButton.do {
            $0.tintColor = .black
            $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func clearButtonTapped() {
        searchTextField.text = ""
        filteredItems = []
        tableView.isHidden = true
        tableView.reloadData()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textFieldDidChange() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            filteredItems = []
            tableView.isHidden = true
            tableView.reloadData()
            return
        }
        
        filteredItems = allItems.filter {
            $0.title.contains(searchText) || $0.description.contains(searchText)
        }
        tableView.isHidden = filteredItems.isEmpty
        tableView.reloadData()
    }
    
    func setConstraints() {
        let horizontalStackView = UIStackView(arrangedSubviews: [backButton, searchTextField])
        horizontalStackView.spacing = 8
        
        view.addSubview(horizontalStackView)
        view.addSubview(tableView)
        
        horizontalStackView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        searchTextField.addSubview(clearButton)
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(horizontalStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Firestore 데이터 로드
    private func loadData() {
        let db = Firestore.firestore()
        db.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("오류: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var items: [Item] = []
            
            for document in documents {
                let documentId = document.documentID
                guard let nickname = document.data()["nickname"] as? String,
                      let title = document.data()["title"] as? String,
                      let price = document.data()["price"] as? String,
                      let content = document.data()["content"] as? String,
                      let timestamp = document.data()["timestamp"] as? Timestamp,
                      let imageUrls = document.data()["imageUrls"] as? [String],
                      let imageUrlString = imageUrls.first,
                      let imageUrl = URL(string: imageUrlString) else {
                    continue
                }
                
                dispatchGroup.enter()
                self.downloadImage(from: imageUrl) { image in
                    let formattedPrice = self.formatPrice(price)
                    let relativeDate = self.relativeDateString(for: timestamp.dateValue())
                    
                    let item = Item(id: documentId,nickname: nickname, image: image, title: title, description: content, price: formattedPrice, date: relativeDate, heartIcon: UIImage(named: "heartIcon"), heartNumber: nil,isCompleted: false)
                    items.append(item)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.allItems = items
                self.filteredItems = items
                self.tableView.reloadData()
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    private func formatPrice(_ price: String) -> String {
        return "\(price) 원"
    }
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
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.id, for: indexPath) as! HomeTableViewCell
        let item = filteredItems[indexPath.row]
        cell.selectionStyle = .none
        cell.titleLabel.text = item.title
        cell.priceLabel.text = item.price
        cell.dateLabel.text = item.date
        cell.heartNumberLabel.text = item.heartNumber
        cell.heartIcon.image = item.heartIcon
        cell.thumbnailImageView.image = item.image
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredItems[indexPath.row]
        let detailVC = ItemDetailViewController(item: item)
        detailVC.item = item
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
}




