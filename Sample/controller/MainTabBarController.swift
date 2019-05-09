//
//  MainTabBarController.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Properties
    lazy var configuration = UIConfiguration()

    
    // MARK: - Initializers
    
    convenience init() {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.delegate = self
        
        setupTabBar()
    }

    // MARK: - Helpers
    
    private func setupTabBar() {
        //items
        let itemsVC = ItemsController(configuration: configuration)
        let itemsNavController = templateNavController(title: "Items", imageName: "items", rootViewController: itemsVC)

        let paymentVC = PaymentController(configuration: configuration)
        let paymentNavController = templateNavController(title: "Payment", imageName: "payment", rootViewController: paymentVC)

        let checkoutVC = CheckoutController(configuration: configuration)
        let checkoutNavController = templateNavController(title: "Checkout", imageName: "checkout", rootViewController: checkoutVC)

        self.viewControllers = [itemsNavController, checkoutNavController, paymentNavController]
        
        tabBar.tintColor = configuration.buttonColor
         #warning("Use color codes from Payment SDK")
        tabBar.barTintColor = configuration.cellBackgroundColor
    }
    
    func templateNavController(title: String, imageName: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController  = CustomNavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = UIImage(named: imageName)
        navController.tabBarItem.title = title
//        navController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font : UIConstants.defaultFont(of: 10, type: UIConstants.DefaultFontType.medium)], for: .normal)
        return navController
    }
}

//extension MainTabBarController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        print("Here")
//        return true
//    }
//}
