//
//  PayPalUIManager.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 25/04/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import BraintreeCore
import BraintreePayPal
import MobilabPaymentCore
import UIKit


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
    
    func showPayPalUI() {
        
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
            } else if let error = error {
                self.errorWhileUsingPayPal?(MobilabPaymentError.other(GenericErrorDetails.from(error: error)))
            } else {
                // Buyer canceled payment approval
                self.errorWhileUsingPayPal?(MobilabPaymentError.psp(BraintreeError.userCancelledPayPal))
            }
            self.viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - BTViewControllerPresentingDelegate
    
    func paymentDriver(_: Any, requestsDismissalOf _: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
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
