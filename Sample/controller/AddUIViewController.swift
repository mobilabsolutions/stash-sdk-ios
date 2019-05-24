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
    @IBOutlet private var useTestModeSwitch: UISwitch!
    @IBOutlet private var pspPickerView: UIPickerView!
    @IBOutlet private var specificPaymentMethodControl: UISegmentedControl!
    @IBOutlet private var triggerSpecificRegisterButton: UIButton!

    private let pspTypes = [MobilabPaymentProvider.bsPayone, MobilabPaymentProvider.adyen]
    private let paymentMethodTypes = [PaymentMethodType.creditCard, PaymentMethodType.sepa, PaymentMethodType.payPal]
    private var pspIsSetUp = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.triggerRegisterUIButton.layer.cornerRadius = 5
        self.triggerRegisterUIButton.layer.masksToBounds = true

        self.triggerRegisterUIButton.addTarget(self, action: #selector(self.triggerRegisterUI), for: .touchUpInside)
        self.triggerSpecificRegisterButton.addTarget(self, action: #selector(self.triggerSpecificRegisterUI), for: .touchUpInside)

        self.pspPickerView.delegate = self
        self.pspPickerView.dataSource = self
    }

    @objc private func triggerRegisterUI() {
        self.startRegistration(paymentMethodType: nil)
    }

    @objc private func triggerSpecificRegisterUI() {
        self.startRegistration(paymentMethodType: self.paymentMethodTypes[specificPaymentMethodControl.selectedSegmentIndex])
    }

    private func startRegistration(paymentMethodType: PaymentMethodType?) {
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
        MobilabPaymentSDK.getRegistrationManager()
            .registerPaymentMethodUsingUI(on: self, specificPaymentMethod: paymentMethodType) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(value):
                        self?.dismiss(animated: true) {
                            self?.showAlert(title: "Success", body: "Successfully registered payment method")
                        }

                        let alias = Alias(alias: value.alias ?? "No alias provided",
                                          humanReadableId: value.humanReadableIdentifier,
                                          expirationYear: nil,
                                          expirationMonth: nil,
                                          type: AliasType(paymentMethodType: value.paymentMethodType))
                        AliasManager.shared.save(alias: alias)
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

        let pspBraintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Sample.paypal")
        MobilabPaymentSDK.registerProvider(provider: pspBraintree, forPaymentMethodTypes: .payPal)

        pspIsSetUp = true
    }

    private func configureSDK(testModeEnabled: Bool) {
        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn", endpoint: "https://payment-dev.mblb.net/api/v1")
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
