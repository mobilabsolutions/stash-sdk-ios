//
//  RegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public class RegistrationManager {
    public func registerCreditCard(billingData: BillingData, creditCardData: CreditCardData, completion: @escaping RegistrationResult) {
        let request: RegisterRequestData = RegisterRequestData(cardMask: "VISA-123",
                                                               type: PaymentMethodType.creditCard)
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: creditCardData, requestData: request)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    public func registerSEPAAccount(billingData: BillingData, sepaData: SEPAData, completion: @escaping RegistrationResult) {
        let request: RegisterRequestData = RegisterRequestData(cardMask: "",
                                                               type: PaymentMethodType.sepa)
        let paymentMethod = MLPaymentMethod(billingData: billingData, methodData: sepaData, requestData: request)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }
}
