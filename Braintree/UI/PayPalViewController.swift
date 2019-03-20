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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.view.backgroundColor = UIColor.clear

        #warning("Change it to read tokenization key from module settings")
        let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIxZWExMGVjMzhjMThiNDIwOWQwYzgyZTM5MDI0NDdlNmFkNjk1ZDNjNDdhNWM2YTlmNzA0Mjg1OWMyMTg3ZDcyfGNyZWF0ZWRfYXQ9MjAxOS0wMy0xNFQyMDoxMzowMi45OTk2NTE1ODkrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJncmFwaFFMIjp7InVybCI6Imh0dHBzOi8vcGF5bWVudHMuc2FuZGJveC5icmFpbnRyZWUtYXBpLmNvbS9ncmFwaHFsIiwiZGF0ZSI6IjIwMTgtMDUtMDgifSwiY2hhbGxlbmdlcyI6W10sImVudmlyb25tZW50Ijoic2FuZGJveCIsImNsaWVudEFwaVVybCI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb206NDQzL21lcmNoYW50cy8zNDhwazljZ2YzYmd5dzJiL2NsaWVudF9hcGkiLCJhc3NldHNVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbSIsImF1dGhVcmwiOiJodHRwczovL2F1dGgudmVubW8uc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbSIsImFuYWx5dGljcyI6eyJ1cmwiOiJodHRwczovL29yaWdpbi1hbmFseXRpY3Mtc2FuZC5zYW5kYm94LmJyYWludHJlZS1hcGkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="

        // Example: Initialize BTAPIClient, if you haven't already
        guard let braintreeClient = BTAPIClient(authorization: clientToken) else {
            fatalError("Braintree client can't be authorized with applied tokenization key")
        }
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional

        let request = BTPayPalRequest()
        request.billingAgreementDescription = "Your agremeent description" // Displayed in customer's PayPal account
        payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                let payPalData = PayPalData(nonce: tokenizedPayPalAccount.nonce)
                self.didCreatePaymentMethodCompletion?(payPalData)
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                #warning("Handle request billing agreement error here")
                self.dismiss(animated: true, completion: nil)
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

    // MARK: - BTAppSwitchDelegate

    func appSwitcherWillPerformAppSwitch(_: Any) {}

    func appSwitcher(_: Any, didPerformSwitchTo _: BTAppSwitchTarget) {}

    func appSwitcherWillProcessPaymentInfo(_: Any) {}
}
