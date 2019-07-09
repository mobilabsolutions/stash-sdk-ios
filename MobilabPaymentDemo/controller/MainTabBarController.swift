//
//  MainTabBarController.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import CoreData
import MobilabPaymentCore
import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Properties

    private let configuration = PaymentMethodUIConfiguration()

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

        let checkoutVC = CheckoutController(configuration: configuration)
        let checkoutNavController = self.templateNavigationController(tabTitle: "Check-out", tabImage: UIConstants.checkoutImage, rootViewController: checkoutVC)

        let paymentVC = PaymentMethodController(configuration: configuration)
        let paymentNavController = self.templateNavigationController(tabTitle: "Payment", tabImage: UIConstants.paymentImage, rootViewController: paymentVC)

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
