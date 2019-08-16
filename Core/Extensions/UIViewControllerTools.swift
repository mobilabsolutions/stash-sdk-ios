//
//  UIViewController+Extensions.swift
//  StashBSPayone
//
//  Created by Robert on 20.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// Tools for typical UIViewController tasks
public final class UIViewControllerTools {
    private init() {}

    private static let alertBannerHeight: CGFloat = 64

    /// Present an alert (UIAlertController) with a single "done" button
    ///
    /// - Parameters:
    ///   - viewController: The view controller which to present the alert on
    ///   - title: The alert's title
    ///   - body: The alert's body
    public class func showAlert(on viewController: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

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
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: alertBannerHeight),
            banner.heightAnchor.constraint(lessThanOrEqualToConstant: alertBannerHeight * 1.5),
        ])

        return banner
    }
}
