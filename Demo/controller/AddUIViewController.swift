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
    @IBOutlet private var customConfigurationSwitch: UISwitch!
    @IBOutlet var useTestModeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.triggerRegisterUIButton.layer.cornerRadius = 5
        self.triggerRegisterUIButton.layer.masksToBounds = true

        self.triggerRegisterUIButton.addTarget(self, action: #selector(self.triggerRegisterUI), for: .touchUpInside)
        self.useTestModeSwitch.addTarget(self, action: #selector(self.didToggleTestMode), for: .valueChanged)
    }

    @objc private func triggerRegisterUI() {
        let configuration: PaymentMethodUIConfiguration

        if self.customConfigurationSwitch.isOn {
            configuration = PaymentMethodUIConfiguration(backgroundColor: .white,
                                                         textColor: .blue,
                                                         buttonColor: .red,
                                                         mediumEmphasisColor: .black,
                                                         cellBackgroundColor: .lightGray)
        } else {
            configuration = PaymentMethodUIConfiguration()
        }

        MobilabPaymentSDK.configureUI(configuration: configuration)
        MobilabPaymentSDK.getRegistrationManager().registerPaymentMethodUsingUI(on: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(value):
                    self?.dismiss(animated: true) {
                        self?.showAlert(title: "Success", body: "Successfully registered payment method")
                    }
                    AliasManager.shared.save(alias: Alias(alias: value, expirationYear: nil, expirationMonth: nil, type: .unknown))
                case let .failure(error):
                    self?.dismiss(animated: true, completion: {
                        self?.showAlert(title: "Error", body: error.failureReason ?? "An error occurred while adding a payment method")
                    })
                    print("An error occurred while creating a payment method")
                }
            }
        }
    }

    @objc private func didToggleTestMode() {
        guard let mainTabBar = self.tabBarController as? MainTabBarController
        else { return }

        mainTabBar.didSetTestMode(enabled: self.useTestModeSwitch.isOn)
    }
}
