//
//  AddUIViewController.swift
//  Demo
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashAdyen
import StashBraintree
import StashBSPayone
import StashCore
import UIKit

let testModeDefaultEnabled = true

class AddUIViewController: UIViewController {
    @IBOutlet private var triggerRegisterUIButton: UIButton!
    @IBOutlet private var customConfigurationSwitch: UISwitch!
    @IBOutlet private var useTestModeSwitch: UISwitch!
    @IBOutlet private var pspPickerView: UIPickerView!
    @IBOutlet private var specificPaymentMethodControl: UISegmentedControl!
    @IBOutlet private var triggerSpecificRegisterButton: UIButton!

    private let pspTypes = [StashPaymentProvider.bsPayone, StashPaymentProvider.adyen, StashPaymentProvider.braintree]

    private let paymentMethodTypes = [PaymentMethodType.creditCard, PaymentMethodType.sepa, PaymentMethodType.payPal]
    private var pspIsSetUp = false
    private var sdkWasInitialized = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.triggerRegisterUIButton.layer.cornerRadius = 5
        self.triggerRegisterUIButton.layer.masksToBounds = true

        self.triggerRegisterUIButton.addTarget(self, action: #selector(self.triggerRegisterUI), for: .touchUpInside)
        self.triggerSpecificRegisterButton.addTarget(self, action: #selector(self.triggerSpecificRegisterUI), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)

        self.pspPickerView.delegate = self
        self.pspPickerView.dataSource = self
    }

    @objc private func triggerRegisterUI() {
        self.startRegistration(paymentMethodType: nil)
    }

    @objc private func triggerSpecificRegisterUI() {
        self.startRegistration(paymentMethodType: self.paymentMethodTypes[specificPaymentMethodControl.selectedSegmentIndex])
    }

    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }

    private func startRegistration(paymentMethodType: PaymentMethodType?) {
        self.configureSDK(testModeEnabled: self.useTestModeSwitch.isOn, psp: self.pspTypes[pspPickerView.selectedRow(inComponent: 0)])

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

        Stash.configureUI(configuration: configuration)
        Stash.getRegistrationManager()
            .registerPaymentMethodUsingUI(on: self, specificPaymentMethod: paymentMethodType) { [weak self] result in
                guard let self = self
                else { return }

                DispatchQueue.main.async {
                    switch result {
                    case let .success(value):
                        if self.presentedViewController != nil {
                            self.dismiss(animated: true) {
                                self.showAlert(title: "Success", body: "Successfully registered payment method")
                            }
                        } else {
                            self.showAlert(title: "Success", body: "Successfully registered payment method")
                        }

                        let extraInfo: String?

                        switch value.extraAliasInfo {
                        case let .creditCard(details):
                            extraInfo = details.creditCardMask
                        case let .sepa(details):
                            extraInfo = details.maskedIban
                        case let .payPal(details):
                            extraInfo = details.email
                        }

                        let alias = Alias(alias: value.alias ?? "No alias provided",
                                          extraInfo: extraInfo,
                                          expirationYear: nil,
                                          expirationMonth: nil,
                                          type: AliasType(paymentMethodType: value.paymentMethodType))
                        AliasManager.shared.save(alias: alias)
                    case let .failure(error):
                        if self.presentedViewController == nil {
                            self.showAlert(title: "Error", body: error.description)
                        }
                    }
                }
            }
    }

    private func configureSDK(testModeEnabled: Bool, psp: StashPaymentProvider) {
        guard !self.sdkWasInitialized
        else { return }

        let adyen = StashAdyen()
        let bsPayOne = StashBSPayone()
        let braintree = StashBraintree(urlScheme: "com.mobilabsolutions.stash.Sample.paypal")

        let providerIntegration: PaymentProviderIntegration
        let braintreeIntegration: PaymentProviderIntegration

        switch psp {
        case .adyen:
            providerIntegration = PaymentProviderIntegration(paymentServiceProvider: adyen,
                                                             paymentMethodTypes: [.sepa, .creditCard])!
            braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree,
                                                              paymentMethodTypes: [.payPal])!
        case .braintree:
            providerIntegration = PaymentProviderIntegration(paymentServiceProvider: bsPayOne,
                                                             paymentMethodTypes: [.sepa])!
            braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree,
                                                              paymentMethodTypes: [.creditCard, .payPal])!
        case .bsPayone: fallthrough
        default:
            providerIntegration = PaymentProviderIntegration(paymentServiceProvider: bsPayOne,
                                                             paymentMethodTypes: [.creditCard, .sepa])!
            braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree,
                                                              paymentMethodTypes: [.payPal])!
        }

        let configuration = StashConfiguration(publishableKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                               endpoint: "https://payment-dev.mblb.net/api/v1",
                                               integrations: [braintreeIntegration, providerIntegration])
        configuration.loggingLevel = .normal
        configuration.useTestMode = testModeEnabled

        Stash.initialize(configuration: configuration)

        self.useTestModeSwitch.isEnabled = false
        self.sdkWasInitialized = true
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

extension AddUIViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
