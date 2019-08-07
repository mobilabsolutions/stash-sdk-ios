//
//  PayPalUIManager.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 25/04/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import BraintreeCore
import BraintreeDataCollector
import BraintreePayPal
import MobilabPaymentCore
import UIKit

/// The manager for presenting, extracting relevant payment method information and dismissing PayPal UI.
class PayPalUIManager: NSObject, PaymentMethodDataProvider, BTAppSwitchDelegate, BTViewControllerPresentingDelegate {
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)?
    var errorWhileUsingPayPal: ((MobilabPaymentError) -> Void)?

    private let viewController: UIViewController
    private let clientToken: String

    init(viewController: UIViewController, clientToken: String) {
        self.viewController = viewController
        self.clientToken = clientToken
        super.init()
    }

    /// Present the PayPal view controller. Calls the `didCreatePaymentMethodCompletion` with the extracted payment method data once that is available.
    func showPayPalUI() {
        guard let braintreeClient = BTAPIClient(authorization: clientToken) else {
            fatalError("Braintree client can't be authorized with applied client token")
        }

        let dataCollector = BTDataCollector(apiClient: braintreeClient)

        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self

        let request = BTPayPalRequest()
        payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                dataCollector.collectCardFraudData { deviceData in
                    let payPalData = PayPalData(nonce: tokenizedPayPalAccount.nonce, deviceData: deviceData, email: tokenizedPayPalAccount.email)
                    self.didCreatePaymentMethodCompletion?(payPalData)
                }
            } else if let error = error {
                self.errorWhileUsingPayPal?(MobilabPaymentError.other(GenericErrorDetails.from(error: error)))
            } else {
                // Buyer canceled payment approval
                let error = BraintreeError.userCancelledPayPal.asMobilabPaymentError()
                 self.errorWhileUsingPayPal?(error)
            }
        }
    }

    // MARK: - BTViewControllerPresentingDelegate

    func paymentDriver(_: Any, requestsDismissalOf _: UIViewController) {
        self.viewController.dismiss(animated: true, completion: nil)
    }

    func paymentDriver(_: Any, requestsPresentationOf viewController: UIViewController) {
        viewController.view.accessibilityIdentifier = "PayPalView"
        viewController.present(viewController, animated: true, completion: nil)
    }

    // MARK: - BTAppSwitchDelegate

    func appSwitcherWillPerformAppSwitch(_: Any) {}

    func appSwitcher(_: Any, didPerformSwitchTo _: BTAppSwitchTarget) {}

    func appSwitcherWillProcessPaymentInfo(_: Any) {}
}
