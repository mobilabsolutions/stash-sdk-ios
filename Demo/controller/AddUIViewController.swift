//
//  AddUIViewController.swift
//  Demo
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

class AddUIViewController: UIViewController {
    @IBOutlet private var triggerRegisterUIButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.triggerRegisterUIButton.layer.cornerRadius = 5
        self.triggerRegisterUIButton.layer.masksToBounds = true

        self.triggerRegisterUIButton.addTarget(self, action: #selector(self.triggerRegisterUI), for: .touchUpInside)
    }

    @objc private func triggerRegisterUI() {
        MobilabPaymentSDK.getRegisterManager().registerPaymentMethodUsingUI(on: self,
                                                                            mobilabProvider: MobilabPaymentProvider.bsPayone,
                                                                            mobilabPayPalProvider: MobilabPaymentProvider.braintree) { [weak self] result in
            switch result {
            case let .success(value):
                self?.dismiss(animated: true) {
                    self?.showAlert(title: "Success", body: "Successfully registered payment method")
                }
                AliasManager.shared.save(alias: Alias(alias: value, expirationYear: nil, expirationMonth: nil, type: .unknown))
            case let .failure(error):
                self?.showAlert(title: "Failure", body: error.errorDescription ?? "An error occurred while adding payment method")
            }
        }
    }
}
