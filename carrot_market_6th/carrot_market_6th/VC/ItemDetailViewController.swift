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

class ItemDetailViewController: UIViewController, UIScrollViewDelegate {
    var item: Item?
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let dateLabel = UILabel()
    private let imageView = UIImageView()
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    let purchaseView = PurchaseView()
    let heartIcon = UIButton()
    let purchaseButton = UIButton()
    private let navigationBar = NavigationBar()
//    private let navigationBarBackgroundView = UIView()
    let profileImage = UIImageView()
    let profileName = UILabel()
    let profileLocation = UILabel()
    private let seperatedView = SeperatedView(height: 1)
    private var images = [UIImage]()
    private let contentView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        setupViews()
        setupConstraints()
        //setnavigationBar()
        setUI()
        setPageControl()
        loadImageUrls()
        configureView()
        addContentScrollView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
//    func setnavigationBar() {
//        view.backgroundColor = .white
//        navigationBarBackgroundView.backgroundColor = .white
//        self.navigationBarBackgroundView.layer.opacity = 0
//        self.navigationController?.navigationBar.barStyle = .black
//    }
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
            $0.textColor = .black
        }
        contentView.do {
            $0.backgroundColor = .clear
        }
    }
    private func setupViews() {
        view.addSubviews(navigationBar,purchaseView)
        view.addSubviews(scrollView, pageControl, profileImage, profileName, seperatedView, titleLabel, dateLabel, descriptionLabel)
    }
    
    private func setupConstraints() {
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(97)
        }
        
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(seperatedView.snp.bottom).offset(10)
            make.leading.equalTo(seperatedView.snp.leading)
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
}

