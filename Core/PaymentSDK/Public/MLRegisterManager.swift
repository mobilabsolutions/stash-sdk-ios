//
//  MLRegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

@objc protocol MLRegisterManagerProtocol: class {
    @objc func registerCreditCardCompleted(paymentAlias: String?, error: MLError?)
    @objc func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?)
}

class MLRegisterManager: NSObject {

    weak var delegate: MLRegisterManagerProtocol!
    
    init(delegate: MLRegisterManagerProtocol) {
        self.delegate = delegate
    }
    
    func registerCreditCard(billingData: MLBillingData, creditCardData: MLCreditCardData, customerID: String?) {
        
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "VISA-123",
                                                                   type: MLPaymentMethodType.MLCreditCard,
                                                                   oneTimePayment: false,
                                                                   customerId: customerID)
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: creditCardData, requestData: request)
        
        MLInternalPaymentSDK.sharedInstance.addMethod(paymentMethod: paymentMethod, success: { paymentAlias in
            print(paymentAlias)
            self.delegate.registerCreditCardCompleted(paymentAlias: paymentAlias, error: nil)
        }) { error in
            print(error)
            self.delegate.registerCreditCardCompleted(paymentAlias: nil, error: error)
        }
    }
    
    func registerSEPAAccount(billingData: MLBillingData, sepaData: MLSEPAData, customerID: String?) {
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "",
                                                                   type: MLPaymentMethodType.MLSEPA,
                                                                   oneTimePayment: false,
                                                                   customerId: customerID)
        
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
