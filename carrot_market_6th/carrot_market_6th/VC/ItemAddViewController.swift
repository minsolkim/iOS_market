//
//  ItemAddViewController.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 6/3/24.
//

import UIKit
import PhotosUI
import AVFoundation
import SnapKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol ItemAddViewControllerDelegate: AnyObject {
    func didSaveNewItem()
}

class ItemAddViewController: UIViewController,UICollectionViewDelegateFlowLayout {
    weak var delegate: ItemAddViewControllerDelegate?
    private lazy var customButton: UIButton = makeCustomButton()
    private var selectedImages: [UIImage] = []
    let barView = UIView()
    let barView2 = UIView()
    let barView3 = UIView()
    let barView4 = UIView()
    let titleTextField = UITextField()
    let contentTextField = UITextField()
    let fullContentTextField = UITextView()
    let textViewPlaceHolder = "올릴 게시글 내용을 적어주세요."
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationControl()
        setConfigure()
        setConstraints()
    }
    
    func navigationControl() {
        navigationItem.title = "내 물건 팔기"
        
        // 'X' 버튼 추가
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        
        // Custom '저장' 버튼 추가
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.orange, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        let saveBarButtonItem = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func makeCustomButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        var attributedTitle = AttributedString("0/5")
        attributedTitle.font = .systemFont(ofSize: 13, weight: .bold)
        config.attributedTitle = attributedTitle
        let pointSize = CGFloat(30)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        config.image = UIImage.init(named: "cameraIcon")
        config.preferredSymbolConfigurationForImage = imageConfig
        
        config.imagePlacement = .top
        config.background.backgroundColor = .white
        config.background.strokeColor = UIColor.warmgray
        config.baseForegroundColor = .lightGray
        config.cornerStyle = .small
        
        // 이미지와 텍스트 간격 조절
        config.imagePadding = 12.7
        config.titlePadding = 10
        let customButton = UIButton(configuration: config)
        customButton.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return customButton
    }
    func setConfigure() {
        barView.do {
            $0.backgroundColor = UIColor.warmgray
        }
        titleTextField.do {
            $0.font = .systemFont(ofSize: 18)
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "글 제목", attributes: [NSAttributedString.Key.foregroundColor : UIColor.warmgray])
        }
        
        barView2.do {
            $0.backgroundColor = UIColor.warmgray
        }
        
        contentTextField.do {
            $0.font = .systemFont(ofSize: 17)
            $0.textColor = .black
            $0.attributedPlaceholder = NSAttributedString(string: "₩ 가격(선택사항)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.warmgray])
            $0.keyboardType = .numberPad
            $0.delegate = self
        }
        barView3.do {
            $0.backgroundColor = UIColor.warmgray
        }
        
        fullContentTextField.do {
            $0.font = .systemFont(ofSize: 15)
            $0.textColor = .warmgray
            $0.textAlignment = .left
            $0.text = textViewPlaceHolder
            $0.delegate = self
        }
        
        barView4.do {
            $0.backgroundColor = UIColor.warmgray
        }
    }
    

    
    func setConstraints() {
        view.addSubviews(customButton,collectionView,barView,titleTextField,barView2,contentTextField,barView3,fullContentTextField,barView4)
        customButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalToSuperview().inset(20)
            $0.height.width.equalTo(80)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalTo(customButton.snp.trailing).offset(20)
            $0.height.equalTo(80)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        barView.snp.makeConstraints {
            $0.top.equalTo(customButton.snp.bottom).offset(20)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(barView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        barView2.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(10)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentTextField.snp.makeConstraints {
            $0.top.equalTo(barView2.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        barView3.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        fullContentTextField.snp.makeConstraints {
            $0.top.equalTo(barView3.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(150)
        }
        
        barView4.snp.makeConstraints {
            $0.top.equalTo(fullContentTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
    }
    
    func pickImage(){
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        
        configuration.selectionLimit = 5 //한번에 가지고 올 이미지 갯수 제한
        configuration.filter = .any(of: [.images]) // 이미지, 비디오 등의 옵션
        
        DispatchQueue.main.async { // 메인 스레드에서 코드를 실행시켜야함
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            picker.isEditing = true
            self.present(picker, animated: true, completion: nil) // 갤러리뷰 프리젠트
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.width - padding * 2
        let cellSize = collectionViewSize / 2
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1, userInfo: nil)))
            return
        }
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
    
    //MARK: - @objc
    @objc func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let price = contentTextField.text, !price.isEmpty,
              let content = fullContentTextField.text, !content.isEmpty, content != "텍스트 뷰 플레이스 홀더" else {
            showAlert(message: "모든 필드를 채워주세요.")
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            showAlert(message: "로그인이 필요합니다.")
            return
        }
        let email = user.email ?? "Anonymous"
        let nickname = email.components(separatedBy: "@").first ?? "Anonymous"
        var imageUrls: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for image in selectedImages {
            dispatchGroup.enter()
            uploadImageToFirebase(image: image) { result in
                switch result {
                case .success(let url):
                    imageUrls.append(url)
                case .failure(let error):
                    print("Error uploading image: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let postData: [String: Any] = [
                "title": title,
                "price": price,
                "content": content,
                "timestamp": Timestamp(date: Date()),
                "imageUrls": imageUrls,
                "nickname": nickname,
                "heartCount": 0,
                "hearts": [], // heart 상태를 관리할 필드
                "isCompleted" : false
            ]
            
            let db = Firestore.firestore()
            var ref: DocumentReference? = nil
            ref = db.collection("posts").addDocument(data: postData) { error in
                if let error = error {
                    self.showAlert(message: "데이터를 저장하는 데 실패했습니다: \(error.localizedDescription)")
                } else {
                    if let documentID = ref?.documentID {
                        print("Document ID: \(documentID)")
                        // Do something with the documentID if needed
                    }
                    self.delegate?.didSaveNewItem()
                    self.dismiss(animated: true)
                }
            }
        }
    }


    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //adjustViewForKeyboard(show: true, keyboardHeight: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // adjustViewForKeyboard(show: false, keyboardHeight: 0)
    }
    // 'X' 버튼 클릭 시 호출될 메서드
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func photoButtonTapped() {
        let actionSheet = UIAlertController(title: "사진 선택", message: "원하는 방법을 선택하세요", preferredStyle: .actionSheet)
        
        let chooseFromLibraryAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { _ in
            self.collectionView.isHidden = false
            self.touchUpImageAddButton(button: self.customButton)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        chooseFromLibraryAction.setValue(UIColor.white, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(chooseFromLibraryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func touchUpImageAddButton(button: UIButton) {
        // 갤러리 접근 권한 허용 여부 체크
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                DispatchQueue.main.async {
                    self.showAlert(message: "갤러리를 불러올 수 없습니다. 핸드폰 설정에서 사진 접근 허용을 모든 사진으로 변경해주세요.")
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.showAlert(message: "갤러리를 불러올 수 없습니다. 핸드폰 설정에서 사진 접근 허용을 모든 사진으로 변경해주세요.")
                }
            case .authorized, .limited: // 모두 허용, 일부 허용
                self.pickImage() // 갤러리 불러오는 동작을 할 함수
            @unknown default:
                print("PHPhotoLibrary::execute - \"Unknown case\"")
            }
        }
    }
}
extension ItemAddViewController: PHPickerViewControllerDelegate {
    // 사진 선택이 끝났을 때 호출되는 함수
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        let group = DispatchGroup()
        fetchResult.enumerateObjects { asset, index, pointer in
            
        }
        for result in results {
            group.enter()
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error loading image: \(error)")
                        group.leave()
                        return
                    }
                    
                    if let image = image as? UIImage {
                        selectedImages.append(image)
                    }
                    
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            // 모든 이미지가 로드되었을 때 실행되는 부분
            DispatchQueue.main.async { [self] in
                    self.collectionView.isHidden = false
                    self.selectedImages = selectedImages
                self.customButton.setTitle("\(selectedImages.count)/5", for: .normal)
                    // 이미지가 추가되었을 때 디버깅 정보 출력
                    print("selectedImages contents: \(self.selectedImages)")
                    
                    self.collectionView.reloadData() // collectionView 갱신
                
            }
            // 이미지 피커를 닫음
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension ItemAddViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoViewCell
        let image = selectedImages[indexPath.item]
        cell.imageView.image = image
        return cell
    }
}
extension ItemAddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        //글자 수 제한
        let maxLength = 100
        if text.count > maxLength {
            textView.text = String(text.prefix(maxLength))
        }
        // 줄바꿈(들여쓰기) 제한
        let maxNumberOfLines = 4
        let lineBreakCharacter = "\n"
        let lines = text.components(separatedBy: lineBreakCharacter)
        var consecutiveLineBreakCount = 0 // 연속된 줄 바꿈 횟수
        
        for line in lines {
            if line.isEmpty {
                consecutiveLineBreakCount += 1
            } else {
                consecutiveLineBreakCount = 0
            }

            if consecutiveLineBreakCount > maxNumberOfLines {
                textView.text = String(text.dropLast())
                break
            }
        }
    }
}
extension ItemAddViewController: UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       if textView.text == textViewPlaceHolder {
           textView.text = nil
           textView.textColor = .black
       }
    }

   func textViewDidEndEditing(_ textView: UITextView) {
       if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
           textView.text = textViewPlaceHolder
           textView.textColor = .lightGray
       }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let newString = currentText.replacingCharacters(in: range, with: string)
        let digitsOnly = newString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if let formattedNumber = formatNumber(digitsOnly) {
            textField.text = "₩ \(formattedNumber)"
        } else {
            textField.text = "₩ "
        }
        
        return false
    }

    func formatNumber(_ number: String) -> String? {
        guard let numberInt = Int(number) else { return nil }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: numberInt))
    }
}
