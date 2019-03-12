//
//  RegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public class RegistrationManager {
    public func registerCreditCard(creditCardData: CreditCardData, completion: @escaping RegistrationResultCompletion) {
        let request: RegisterRequestData = RegisterRequestData(cardMask: "VISA-123",
                                                               type: .creditCard)
        let paymentMethod = MLPaymentMethod(methodData: creditCardData, requestData: request)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    public func registerSEPAAccount(sepaData: SEPAData, completion: @escaping RegistrationResultCompletion) {
        let request = RegisterRequestData(cardMask: "", type: .sepa)
        let paymentMethod = MLPaymentMethod(methodData: sepaData, requestData: request)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }
}
