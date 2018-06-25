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
    @objc func removeCreditCardCompleted(error: MLError?)
    @objc func removeSEPACompleted(error: MLError?)
}

class MLRegisterManager: NSObject {

    weak var delegate: MLRegisterManagerProtocol!
    //var networkClient: MLNetworkClient
    
    init(delegate: MLRegisterManagerProtocol) {
        self.delegate = delegate
    }
    
    func registerCreditCard(billingData: MLBillingData, creditCardData: MLCreditCardData, customerID: String?) {
        
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "VISA-123",
                                                                   type: MLPaymentMethodType.MLCreditCard,
                                                                   oneTime: false,
                                                                   customerId: customerID)
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: creditCardData, requestData: request)
        
        MLInternalPaymentSDK.sharedInstance.addMethod(paymentMethod: paymentMethod, success: { paymentAlias in
            print(paymentAlias)
        }) { error in
            print(error)
        }
    }
    
    func registerSEPAAccount(billingData: MLBillingData, sepaData: MLSEPAData, customerID: String?) {
        
    }
    
    func removeCreditCard(paymentAlias: String) {
        
    }
    
    func removeSEPA(paymentAlias: String) {
        
    }

}
