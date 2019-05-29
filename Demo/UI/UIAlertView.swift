//
//  UIAlertView.swift
//  Demo
//
//  Created by Rupali Ghate on 29.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

final class AlertView {
    private init() {}

    class func showAlert(on viewController: UIViewController, title: String, body: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { _ in
            completion()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
}
