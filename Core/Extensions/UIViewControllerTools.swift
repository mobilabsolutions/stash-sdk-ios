//
//  UIViewController+Extensions.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 20.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public final class UIViewControllerTools {
    private init() {}

    private static let alertBannerHeight: CGFloat = 62

    public class func showAlert(on viewController: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    class func showAlertBanner(on viewController: UIViewController & AlertBannerDelegate, title: String, body: String, uiConfiguration: PaymentMethodUIConfiguration) {
        let banner = AlertBanner(title: title, subtitle: body, configuration: uiConfiguration, delegate: viewController)
        banner.translatesAutoresizingMaskIntoConstraints = false

        let view: UIView = viewController.parent?.view ?? viewController.view
        view.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            banner.heightAnchor.constraint(equalToConstant: alertBannerHeight),
        ])
    }
}
