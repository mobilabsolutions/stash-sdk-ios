//
//  MainTabBarController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Properties

    let configuration = PaymentMethodUIConfiguration()

    // MARK: - Initializers

    convenience init() {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
    }

    // MARK: - Helpers

    private func setupTabBar() {
        // items
        let itemsVC = ItemsController(configuration: configuration)

        let itemsNavController = self.templateNavigationController(tabTitle: "Items", tabImage: UIConstants.itemsImage, rootViewController: itemsVC)

        let paymentVC = PaymentMethodController(configuration: configuration)
        let paymentNavController = self.templateNavigationController(tabTitle: "Payment", tabImage: UIConstants.paymentImage, rootViewController: paymentVC)

        let checkoutVC = CheckoutController(configuration: configuration)
        let checkoutNavController = self.templateNavigationController(tabTitle: "Check-out", tabImage: UIConstants.checkoutImage, rootViewController: checkoutVC)

        self.viewControllers = [itemsNavController, checkoutNavController, paymentNavController]

        tabBar.tintColor = self.configuration.buttonColor
        tabBar.barTintColor = self.configuration.cellBackgroundColor
    }

    func templateNavigationController(tabTitle title: String, tabImage image: UIImage?, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = CustomNavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.title = title

        return navController
    }
}
