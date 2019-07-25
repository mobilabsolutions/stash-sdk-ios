//
//  UIViewController+Extensions.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 20.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

public final class UIViewControllerTools {
    private init() {}

    private static let alertBannerHeight: CGFloat = 64

    public class func showAlert(on viewController: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

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
