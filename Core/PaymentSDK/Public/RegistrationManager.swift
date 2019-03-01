//
//  RegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

@objc public protocol RegisterManagerProtocol: class {
    @objc func registerCreditCardCompleted(paymentAlias: String?, error: MLError?)
    @objc func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?)
}

public class RegistrationManager: NSObject {

    weak var delegate: RegisterManagerProtocol!
    
    init(delegate: RegisterManagerProtocol) {
        self.delegate = delegate
    }
    
    public func registerCreditCard(billingData: MLBillingData, creditCardData: MLCreditCardData) {
        
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "VISA-123",
                                                                   type: MLPaymentMethodType.MLCreditCard,
                                                                   oneTimePayment: false,
                                                                   customerId: "")
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: creditCardData, requestData: request)
        
        MLInternalPaymentSDK.sharedInstance.addMethod(paymentMethod: paymentMethod, success: { paymentAlias in
            print(paymentAlias)
            self.delegate.registerCreditCardCompleted(paymentAlias: paymentAlias, error: nil)
        }) { error in
            print(error)
            self.delegate.registerCreditCardCompleted(paymentAlias: nil, error: error)
        }
    }
    
    func registerSEPAAccount(billingData: MLBillingData, sepaData: MLSEPAData) {
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "",
                                                                   type: MLPaymentMethodType.MLSEPA,
                                                                   oneTimePayment: false,
                                                                   customerId: "")
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: sepaData, requestData: request)
        
        MLInternalPaymentSDK.sharedInstance.addMethod(paymentMethod: paymentMethod, success: { paymentAlias in
            print(paymentAlias)
            self.delegate.registerSEPAAccountCompleted(paymentAlias: paymentAlias, error: nil)
        }) { error in
            print(error)
            self.delegate.registerSEPAAccountCompleted(paymentAlias: nil, error: error)
        }
    }

}
