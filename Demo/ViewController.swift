//
//  ViewController.swift
//  Demo
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit
import MobilabPaymentCore
import MobilabPaymentBSPayone

class ViewController: UIViewController, RegistrationManagerProtocol {
    
    func registerCreditCardCompleted(paymentAlias: String?, error: MLError?) {
        
    }
    
    func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test()
    }

    
    func test() {
        MobilabPaymentSDK.setUp(publicToken: "test", provider: MobilabPaymentBSPayone())
        let registrationManager = MobilabPaymentSDK.createRegisterManager(delegate: self)
        
        let billingData = BillingData(email: "testEmail")
        let creditCardData = CreditCardData(holderName: "holder", cardNumber: "cardNumber", CVV: "cvv", expiryMonth: 1, expiryYear: 1)
        registrationManager.registerCreditCard(billingData: billingData, creditCardData: creditCardData)
    }

}

