//
//  RegistrationFlowNavigationController.swift
//  StashCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

public class RegistrationFlowNavigationController: UINavigationController {
    private var userDidCloseCallback: (() -> Void)?
    private var numberOfFirstViewControllersWithoutBarTint = 1
    private var firstViewControllerShouldHaveTranslucentBar = true
    private let barTintColor = UIConstants.darkRoyalBlue

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public init(rootViewController: UIViewController, userDidCloseCallback: (() -> Void)?, firstViewControllerShouldHaveTranslucentBar: Bool) {
        super.init(rootViewController: rootViewController)
        self.userDidCloseCallback = userDidCloseCallback
        self.firstViewControllerShouldHaveTranslucentBar = firstViewControllerShouldHaveTranslucentBar
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.sharedInit()
    }

    private func sharedInit() {
        self.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIConstants.closeButtonImage, style: .plain, target: self, action: #selector(self.cancel))

        if self.firstViewControllerShouldHaveTranslucentBar {
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.isTranslucent = true
            self.view.backgroundColor = .clear
        } else {
            self.navigationBar.isTranslucent = false
            self.navigationBar.barTintColor = self.barTintColor
        }

        self.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationBar.backIndicatorImage = UIConstants.backButtonImage
        self.navigationBar.backIndicatorTransitionMaskImage = UIConstants.backButtonImage
        self.topViewController?.navigationItem.backBarButtonItem?.tintColor = .white
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

        if self.firstViewControllerShouldHaveTranslucentBar,
            self.viewControllers.count >= self.numberOfFirstViewControllersWithoutBarTint + 1 {
            self.navigationBar.isTranslucent = false
            self.navigationBar.barTintColor = self.barTintColor
        }
    }

    public override func popViewController(animated: Bool) -> UIViewController? {
        if self.firstViewControllerShouldHaveTranslucentBar,
            self.viewControllers.count == self.numberOfFirstViewControllersWithoutBarTint + 1 {
            self.navigationBar.isTranslucent = true
        }

        return super.popViewController(animated: animated)
    }

    @objc private func cancel() {
        self.userDidCloseCallback?()
        self.dismiss(animated: true, completion: nil)
    }
}
