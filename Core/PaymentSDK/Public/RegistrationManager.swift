//
//  RegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

@objc public protocol RegistrationManagerProtocol: class {
    @objc func registerCreditCardCompleted(paymentAlias: String?, error: MLError?)
    @objc func registerSEPAAccountCompleted(paymentAlias: String?, error: MLError?)
}

public class RegistrationManager: NSObject {

    weak var delegate: RegistrationManagerProtocol!
    
    init(delegate: RegistrationManagerProtocol) {
        self.delegate = delegate
    }
    
    public func registerCreditCard(billingData: BillingData, creditCardData: CreditCardData) {
        
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "VISA-123",
                                                                   type: MLPaymentMethodType.MLCreditCard,
                                                                   oneTimePayment: false,
                                                                   customerId: "")
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: creditCardData, requestData: request)
        
        let internalManager = MLInternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod) { (result) in
            
            switch result {
            case .success:
                self.delegate.registerCreditCardCompleted(paymentAlias: "", error: nil)
            case .failure(let error):
                self.delegate.registerCreditCardCompleted(paymentAlias: nil, error: error)
            }
        }
    }
    
    func registerSEPAAccount(billingData: BillingData, sepaData: MLSEPAData) {
        
        let request: MLRegisterRequestData = MLRegisterRequestData(cardMask: "",
                                                                   type: MLPaymentMethodType.MLSEPA,
                                                                   oneTimePayment: false,
                                                                   customerId: "")
        
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: sepaData, requestData: request)
        
        let internalManager = MLInternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod) { (result) in
            
            switch result {
            case .success:
                self.delegate.registerSEPAAccountCompleted(paymentAlias: "", error: nil)
            case .failure(let error):
                self.delegate.registerSEPAAccountCompleted(paymentAlias: nil, error: error)
            }
        }
    }

}
