//
//  SceneDelegate.swift
//  carrot_market_6th
//
//  Created by 김민솔 on 4/7/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 윈도우 객체와 연결된 루트뷰컨트롤러 가져오기
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let viewController1 = FirstViewController()
        let navigationController1 = UINavigationController(rootViewController: viewController1)
        navigationController1.tabBarItem = UITabBarItem(title: "홈", image: resizeImage(image: UIImage(named: "home"), targetSize: CGSize(width: 20, height: 20)), selectedImage: nil)

        let viewController5 = FifthViewController()
        let navigationController5 = UINavigationController(rootViewController: viewController5)
        navigationController5.tabBarItem = UITabBarItem(title: "나의 당근", image: resizeImage(image: UIImage(named: "user"), targetSize: CGSize(width: 20, height: 20)), selectedImage: nil)

        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .black

        tabBarController.setViewControllers([navigationController1, navigationController5], animated: true)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }


}

