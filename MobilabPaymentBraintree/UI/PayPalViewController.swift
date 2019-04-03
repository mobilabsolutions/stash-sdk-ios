//
//  PayPalViewController.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 15/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import BraintreeCore
import BraintreePayPal
import MobilabPaymentCore
import UIKit

class PayPalViewController: UIViewController, PaymentMethodDataProvider, BTAppSwitchDelegate, BTViewControllerPresentingDelegate {
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?

    private let clientToken: String

    init(clientToken: String) {
        self.clientToken = clientToken
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "PayPalView"
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.view.backgroundColor = UIColor.clear

        guard let braintreeClient = BTAPIClient(authorization: clientToken) else {
            fatalError("Braintree client can't be authorized with applied client token")
        }
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self

        let request = BTPayPalRequest()
        payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                let payPalData = PayPalData(nonce: tokenizedPayPalAccount.nonce)
                self.didCreatePaymentMethodCompletion?(payPalData)
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                self.errorWhileCreatingPaymentMethod(error: MobilabPaymentError.pspError(error.localizedDescription))
            } else {
                // Buyer canceled payment approval
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: - BTViewControllerPresentingDelegate

    func paymentDriver(_: Any, requestsDismissalOf _: UIViewController) {
        dismiss(animated: true, completion: nil)
    }

    func paymentDriver(_: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    func errorWhileCreatingPaymentMethod(error: MobilabPaymentError) {
        let alert = UIAlertController(title: error.title, message: error.description,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    // MARK: - BTAppSwitchDelegate

    func appSwitcherWillPerformAppSwitch(_: Any) {}

    func appSwitcher(_: Any, didPerformSwitchTo _: BTAppSwitchTarget) {}

    func appSwitcherWillProcessPaymentInfo(_: Any) {}
}
