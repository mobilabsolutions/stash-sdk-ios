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
        let paymentMethod = PaymentMethod(methodData: creditCardData, type: .creditCard)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    public func registerSEPAAccount(sepaData: SEPAData, completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: sepaData, type: .sepa)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    public func registerPaymentMethodUsingUI(on viewController: UIViewController, completion: @escaping RegistrationResultCompletion) {
        let selectionViewController = PaymentMethodSelectionCollectionViewController()
        selectionViewController.selectablePaymentMethods = InternalPaymentSDK.sharedInstance.provider.supportedPaymentMethodTypeUserInterfaces
        selectionViewController.selectedPaymentMethodCallback = { selectedType in
            guard var paymentMethodViewController = InternalPaymentSDK.sharedInstance.provider.viewController(for: selectedType)
            else { fatalError("Payment method view controller for selected type not present in module") }

            paymentMethodViewController.didCreatePaymentMethodCompletion = { [weak self] method in
                if let creditCardData = method as? CreditCardData {
                    self?.registerCreditCard(creditCardData: creditCardData, completion: completion)
                } else if let sepaData = method as? SEPAData {
                    self?.registerSEPAAccount(sepaData: sepaData, completion: completion)
                } else {
                    print("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData or CreditCardData")
                }
            }

            selectionViewController.navigationController?.pushViewController(paymentMethodViewController, animated: true)
        }

        let navigationController = RegistrationFlowNavigationController(rootViewController: selectionViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
}
