//
//  RegistrationFlowNavigationController.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class RegistrationFlowNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
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
        self.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done,
                                                                                   target: self, action: #selector(self.cancel))
    }

    @objc private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
