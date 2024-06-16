//
//  MyFavoriteViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/6/24.
//
import UIKit
import FirebaseStorage
import Firebase
import FirebaseAuth

class MyFavoriteViewController: UIViewController {
    private var filteredItems: [Item] = []
    
    // 테이블 뷰
    private let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationController()
        tableView.dataSource = self
        tableView.delegate = self
        setConstraints()
        fetchFavoritePost()
    }
    private func setNavigationController() {
        // 뒤로 가기 버튼 아이콘 설정
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "관심목록"
    }
    func setConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func fetchFavoritePost() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("user id is null")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let heartPost = document.data()?["heartPost"] as? [String] {
                    self.fetchPosts(postIDs: heartPost)
                } else {
                    print("heartPost array does not exist")
                }
            } else {
                print("user document does not exist")
            }
        }
    }
    
    private func fetchPosts(postIDs: [String]) {
        let db = Firestore.firestore()
        let dispatchGroup = DispatchGroup()
        var items: [Item] = []
        
        for postID in postIDs {
            db.collection("posts").document(postID).getDocument { document, error in
                if let document = document, document.exists {
                    let documentId = document.documentID
                    let heartCount = document.data()?["heartCount"] as? Int ?? 0
                    let isCompleted = document.data()?["isCompleted"] as? Bool ?? false
                    guard let nickname = document.data()?["nickname"] as? String,
                          let title = document.data()?["title"] as? String,
                          let price = document.data()?["price"] as? String,
                          let content = document.data()?["content"] as? String,
                          let timestamp = document.data()?["timestamp"] as? Timestamp,
                          let imageUrls = document.data()?["imageUrls"] as? [String],
                          let imageUrlString = imageUrls.first,
                          let imageUrl = URL(string: imageUrlString) else {
                        return
                    }
                    
                    dispatchGroup.enter()
                    self.downloadImage(from: imageUrl) {
                        image in
                        let formattedPrice = self.formatPrice(price)
                        let relativeDate = self.relativeDateString(for: timestamp.dateValue())
                        
                        let item = Item(id: documentId,nickname: nickname, image: image, title: title, description: content, price: formattedPrice, date: relativeDate, heartIcon: UIImage(named: "heartIcon"), heartNumber: "\(heartCount)",isCompleted: isCompleted)
                        items.append(item)
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.filteredItems = items
                    self.tableView.reloadData()
                }
            }
        }
        
        
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
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}

extension MyFavoriteViewController: UITableViewDataSource, UITableViewDelegate {
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

