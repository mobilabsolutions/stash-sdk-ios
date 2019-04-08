//
//  AddUIViewController.swift
//  Demo
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentAdyen
import MobilabPaymentBraintree
import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

let testModeDefaultEnabled = true

class AddUIViewController: UIViewController {
    @IBOutlet private var triggerRegisterUIButton: UIButton!
    @IBOutlet private var customConfigurationSwitch: UISwitch!
    @IBOutlet var useTestModeSwitch: UISwitch!
    @IBOutlet var pspPickerView: UIPickerView!

    private let pspTypes = [MobilabPaymentProvider.bsPayone, MobilabPaymentProvider.adyen]
    private var pspIsSetUp = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.triggerRegisterUIButton.layer.cornerRadius = 5
        self.triggerRegisterUIButton.layer.masksToBounds = true

        self.triggerRegisterUIButton.addTarget(self, action: #selector(self.triggerRegisterUI), for: .touchUpInside)

        self.pspPickerView.delegate = self
        self.pspPickerView.dataSource = self
    }

    @objc private func triggerRegisterUI() {
        self.setupPspForSDK(psp: self.pspTypes[pspPickerView.selectedRow(inComponent: 0)])
        self.configureSDK(testModeEnabled: self.useTestModeSwitch.isOn)

        self.pspPickerView.isUserInteractionEnabled = false
        self.pspPickerView.alpha = 0.5

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
                case .failure:
                    break
                }
            }
        }
    }

    private func setupPspForSDK(psp: MobilabPaymentProvider) {
        guard !pspIsSetUp
        else { return }

        let provider: PaymentServiceProvider

        switch psp {
        case .adyen:
            provider = MobilabPaymentAdyen()
        case .bsPayone: fallthrough
        default:
            provider = MobilabPaymentBSPayone()
        }

        MobilabPaymentSDK.registerProvider(provider: provider, forPaymentMethodTypes: .creditCard, .sepa)

        let pspBraintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        MobilabPaymentSDK.registerProvider(provider: pspBraintree, forPaymentMethodTypes: .payPal)

        pspIsSetUp = true
    }

    private func configureSDK(testModeEnabled: Bool) {
        let configuration = MobilabPaymentConfiguration(publicKey: "PD-BS2-nF7kU7xY8ESLgflavGW9CpUv1I", endpoint: "https://payment-dev.mblb.net/api/v1")
        configuration.loggingEnabled = true
        configuration.useTestMode = testModeEnabled

        MobilabPaymentSDK.configure(configuration: configuration)
    }
}

extension AddUIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.pspTypes.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return self.pspTypes[row].rawValue
    }
}
