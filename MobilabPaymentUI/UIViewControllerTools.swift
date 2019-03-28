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

    public class func showAlert(on viewController: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
