//
//  RegistrationFlowNavigationController.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
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
        self.topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIConstants.closeButtonImage, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear

        self.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationBar.backIndicatorImage = UIConstants.backButtonImage
        self.navigationBar.backIndicatorTransitionMaskImage = UIConstants.backButtonImage
    }

    @objc private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
