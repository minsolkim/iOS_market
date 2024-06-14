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
    private var filteredItems : [Item] = []
    //테이블 뷰
    private let tableView = UITableView().then {
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        $0.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.id)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setConstraints() {
        view.addSubviews(tableView)
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
                    print("heartpost array does not exist")
                }
            } else {
                print("user document does not exist")
            }
        }
    }
    
//    private func fetchPosts(postIDs: [String]) {
//         let db = Firestore.firestore()
//         let group = DispatchGroup()
//         var items: [Item] = []
//
//         for postID in postIDs {
//             group.enter()
//             db.collection("posts").document(postID).getDocument { document, error in
//                 if let document = document, document.exists {
//                     if let data = document.data() {
//                         // Map Firestore document data to Item model
//                         let item = Item(
//                             id: postID,
//                             title: data["title"] as? String ?? "",
//                             price: data["price"] as? String ?? "",
//                             date: data["date"] as? String ?? "",
//                             heartNumber: "\(data["heartCount"] as? Int ?? 0)",
//                             heartIcon: UIImage(named: "heart") ?? UIImage(),
//                             image: UIImage(named: "defaultImage") ?? UIImage() // Replace with actual image fetching logic
//                         )
//                         items.append(item)
//                     }
//                 } else {
//                     print("Post document does not exist: \(error?.localizedDescription ?? "Unknown error")")
//                 }
//                 group.leave()
//             }
//         }
//
//         group.notify(queue: .main) {
//             self.filteredItems = items
//             self.tableView.reloadData()
//         }
//     }
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




