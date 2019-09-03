//
//  UIViewControllerTools+Banner.swift
//  Stash
//
//  Created by Robert on 03.09.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashCore
import UIKit

extension UIViewControllerTools {
    private static let alertBannerHeight: CGFloat = 64

    /// Present an alert banner on a view controller
    ///
    /// - Parameters:
    ///   - viewController: The view controller that the alert banner should be presented on
    ///   - title: The alert's title
    ///   - body: The alert's body
    ///   - uiConfiguration: The UI configuration that should be used to style the alert
    /// - Returns: The alert banner that is being presented
    class func showAlertBanner(on viewController: UIViewController & AlertBannerDelegate, title: String, body: String, uiConfiguration: PaymentMethodUIConfiguration) -> AlertBanner {
        let banner = AlertBanner(title: title, subtitle: body, configuration: uiConfiguration, delegate: viewController)
        banner.translatesAutoresizingMaskIntoConstraints = false

        let view: UIView = viewController.parent?.view ?? viewController.view
        view.addSubview(banner)

        banner.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                      leading: view.safeAreaLayoutGuide.leadingAnchor,
                      trailing: view.safeAreaLayoutGuide.trailingAnchor)

        NSLayoutConstraint.activate([
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: UIViewControllerTools.alertBannerHeight),
            banner.heightAnchor.constraint(lessThanOrEqualToConstant: UIViewControllerTools.alertBannerHeight * 1.5),
        ])

        return banner
    }
}
