//
//  ItemDetailViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/4/24.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

protocol ItemDetailViewControllerDelegate: AnyObject {
    func didDeleteItem(_ item: Item)
}

class ItemDetailViewController: UIViewController, UIScrollViewDelegate {
    weak var delegate: ItemDetailViewControllerDelegate?
    var item: Item?
    private var currentUserNickname: String?
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let dateLabel = UILabel()
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let heartIcon = UIButton()
    private let purchaseButton = UIButton()
    private let profileImage = UIImageView()
    private let profileName = UILabel()
    private let profileLocation = UILabel()
    private let seperatedView = SeperatedView(height: 1)
    private var images = [UIImage]()
    private let contentView = UIView()
    private let statusButton = UIButton()
    private let purchaseView: PurchaseView
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        setupViews()
        setupConstraints()
        setUI()
        setPageControl()
        loadImageUrls()
        configureView()
        addContentScrollView()
        checkIfCurrentUserIsAuthor()
        setupCustomNavigationBar()
        checkIsCompleted()
    
    }
    init(item: Item) {
        self.item = item
        self.purchaseView = PurchaseView(itemId: item.id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setUI() {
        profileImage.do {
            $0.image = UIImage.init(named: "profile")
        }
        profileName.do {
            $0.text = "name"
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 15)
        }
        seperatedView.do {
            $0.backgroundColor = .warmgray2
        }
        titleLabel.do {
            $0.font = .boldSystemFont(ofSize: 20)
            $0.textColor = .black
        }
        dateLabel.do {
            $0.font = .systemFont(ofSize: 13)
            $0.textColor = .gray
        }
        descriptionLabel.do {
            $0.font = .boldSystemFont(ofSize: 15)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping // 단어 단위로 줄바꿈
            $0.textColor = .black
        }
        contentView.do {
            $0.backgroundColor = .clear
        }
    }
    
    private func setupCustomNavigationBar() {
        navigationItem.hidesBackButton = true

        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(homeButtonTapped))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(menuButtonTapped))
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItems = [backButton, homeButton]
        navigationItem.rightBarButtonItem = menuButton
        menuButton.isHidden = true // 기본적으로 숨김 처리
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func homeButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    @objc private func menuButtonTapped() {
        let alert = UIAlertController(title: nil, message: "게시글을 삭제할까요?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deletePost()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deletePost() {
        guard let item = item else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Delete main post document
        let postRef = db.collection("posts").document(item.id)
        batch.deleteDocument(postRef)
        
        // Delete 'hearts' subcollection documents
        let heartsRef = postRef.collection("hearts")
        heartsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching hearts documents: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot?.documents ?? [] {
                let docRef = heartsRef.document(document.documentID)
                batch.deleteDocument(docRef)
            }
            
            batch.commit { [weak self] (error) in
                if let error = error {
                    print("Error batch deleting documents: \(error.localizedDescription)")
                } else {
                    print("Batch delete operation successful")
                    if let item = self?.item {
                        self?.delegate?.didDeleteItem(item)
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    
    private func setupViews() {
        view.addSubviews(purchaseView)
        view.addSubviews(scrollView, pageControl, profileImage, profileName, seperatedView, titleLabel, dateLabel, descriptionLabel,statusButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.width * 0.85)
        }
        
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom).offset(-10)
        }
        
        profileImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(pageControl.snp.bottom).offset(15)
            make.height.width.equalTo(50)
        }
        
        profileName.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(10)
            make.top.equalTo(profileImage.snp.top).offset(5)
        }
        
        seperatedView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(profileImage.snp.bottom).offset(10)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.equalTo(dateLabel.snp.leading)
            make.trailing.equalToSuperview().inset(10)
        }
        
        purchaseView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
    }
    
    private func addContentScrollView() {
        scrollView.isPagingEnabled = true
        for i in 0..<images.count {
            let imageView = UIImageView()
            let xPos = scrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(images.count), height: scrollView.frame.height)
        }
        
    }
    
    private func setPageControl() {
        pageControl.numberOfPages = images.count
        
    }
    
    private func setPageControlSelectedPage(currentPage:Int) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width > 0 else { return }
        
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        setPageControlSelectedPage(currentPage: Int(round(value)))
    }
    private func loadImageUrls() {
        guard let item = item else { return }
        
        let db = Firestore.firestore()
        db.collection("posts").document(item.id).getDocument { (document, error) in
            if let document = document, document.exists {
                if let imageUrls = document.data()?["imageUrls"] as? [String] {
                    self.loadImages(from: imageUrls)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func loadImages(from urls: [String]) {
        for (index, urlString) in urls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            downloadImage(from: url) { image in
                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.contentMode = .scaleAspectFill
                    imageView.frame = CGRect(x: self.scrollView.frame.size.width * CGFloat(index), y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
                    self.scrollView.addSubview(imageView)
                    
                    self.scrollView.contentSize.width = self.scrollView.frame.size.width * CGFloat(index + 1)
                }
            }
        }
        
        pageControl.numberOfPages = urls.count
        pageControl.currentPage = 0
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
    private func configureView() {
        guard let item = item else { return }
        titleLabel.text = item.title
        profileName.text = item.nickname
        descriptionLabel.text = item.description
        dateLabel.text = item.date
        imageView.image = item.image
        purchaseView.priceLabel.text = item.price
    }
    
    private func setupStatusButton() {
        statusButton.setTitle("판매중", for: .normal) // 초기 텍스트 설정
        statusButton.setTitleColor(.black, for: .normal)
        statusButton.layer.borderColor = UIColor.warmgray.cgColor
        statusButton.layer.borderWidth = 1
        statusButton.layer.cornerRadius = 10
        statusButton.layer.masksToBounds = true
        statusButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        statusButton.tintColor = .black
        statusButton.semanticContentAttribute = .forceRightToLeft
        statusButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        statusButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        statusButton.addTarget(self, action: #selector(showStatusMenu), for: .touchUpInside)
    }
    private func checkIfCurrentUserIsAuthor() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).getDocument { (document, error) in
            if let document = document, document.exists {
                if let currentUserNickname = document.data()?["nickname"] as? String,
                   let itemNickname = self.item?.nickname {
                    let lowercasedCurrentUserNickname = currentUserNickname.lowercased()
                    let lowercasedItemNickname = itemNickname.lowercased()
                    
                    if lowercasedCurrentUserNickname == lowercasedItemNickname {
                        self.statusButton.isHidden = false
                        self.setupStatusButton()
                        self.navigationItem.rightBarButtonItem?.isHidden = false
                        self.statusButton.snp.makeConstraints { make in
                            make.top.equalTo(self.seperatedView.snp.bottom).offset(10)
                            make.leading.equalTo(self.seperatedView.snp.leading)
                        }
                        self.titleLabel.snp.makeConstraints { make in
                            make.top.equalTo(self.statusButton.snp.bottom).offset(16)
                            make.leading.equalTo(self.seperatedView.snp.leading)
                        }
                    } else {
                        self.statusButton.isHidden = true
                        self.navigationItem.rightBarButtonItem?.isHidden = true
                        self.titleLabel.snp.makeConstraints { make in
                            make.top.equalTo(self.seperatedView.snp.bottom).offset(10)
                            make.leading.equalTo(self.seperatedView.snp.leading)
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func updateStatus(isCompleted: Bool) {
        guard let itemId = item?.id else {
            print("Item ID is nil")
            return
        }
        
        let statusText = isCompleted ? "거래완료" : "판매중"
        statusButton.setTitle(statusText, for: .normal)
        
        let db = Firestore.firestore()
        let itemRef = db.collection("posts").document(itemId)
        
        itemRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 문서가 존재하면 업데이트 수행
                itemRef.updateData(["isCompleted": isCompleted]) { error in
                    if let error = error {
                        print("Failed to update item status: \(error)")
                    } else {
                        print("Item status successfully updated to \(statusText)")
                        //firstviewcontroller 에 전달
                        NotificationCenter.default.post(name: .statusDidChange, object: nil, userInfo: ["itemId": itemId, "isCompleted": isCompleted])

                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func checkIsCompleted() {
        guard let itemId = item?.id else {
            print("Item ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        let itemRef = db.collection("posts").document(itemId)
        
        itemRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let isCompleted = document.data()?["isCompleted"] as? Bool {
                    let statusText = isCompleted ? "거래완료" : "판매중"
                    self.statusButton.setTitle(statusText, for: .normal)
                } else {
                    print("isCompleted field does not exist")
                }
            } else {
                if let error = error {
                    print("Error getting document: \(error)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    @objc private func showStatusMenu() {
        let alertController = UIAlertController(title: "상태 변경", message: nil, preferredStyle: .actionSheet)
        
        let saleAction = UIAlertAction(title: "판매중", style: .default) { _ in
            self.updateStatus(isCompleted: false)
        }
        
        let completedAction = UIAlertAction(title: "거래완료", style: .default) { _ in
            self.updateStatus(isCompleted: true)
        }
        
        let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        
        alertController.addAction(saleAction)
        alertController.addAction(completedAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
extension Notification.Name {
    static let statusDidChange = Notification.Name("statusDidChange")
}

