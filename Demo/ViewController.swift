//
//  ViewController.swift
//  Demo
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentBSPayone
import MobilabPaymentCore
import UIKit

class ViewController: UIViewController {
    func registerCreditCardCompleted(paymentAlias _: String?, error _: MLError?) {}

    func registerSEPAAccountCompleted(paymentAlias _: String?, error _: MLError?) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.test()
    }

    func test() {
//        MobilabPaymentSDK.setUp(publicToken: "test", provider: MobilabPaymentBSPayone())
//        let registrationManager = MobilabPaymentSDK.getRegisterManager()
//
//        let billingData = BillingData(email: "testEmail")
//        let creditCardData = CreditCardData(holderName: "holder", cardNumber: "cardNumber", CVV: "cvv", expiryMonth: 1, expiryYear: 1)
        // registrationManager.registerCreditCard(billingData: billingData, creditCardData: creditCardData)
    }
}
