//
//  UIViewController+Extensions.swift
//  StashBSPayone
//
//  Created by Robert on 20.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit
#if CORE
#else
    import StashCore
#endif

/// Tools for typical UIViewController tasks
final class UIViewControllerTools {
    private init() {}

    /// Present an alert (UIAlertController) with a single "done" button
    ///
    /// - Parameters:
    ///   - viewController: The view controller which to present the alert on
    ///   - title: The alert's title
    ///   - body: The alert's body
    class func showAlert(on viewController: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
