//
//  RegisterManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

/// Type used for registering payment methods of different types
public class RegistrationManager {
    /// Register a credit card with the provider that was configured
    ///
    /// - Parameters:
    ///   - creditCardData: The credit card data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerCreditCard(creditCardData: CreditCardData, completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: creditCardData, type: .creditCard)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    /// Register a SEPA account with the provider that was configured
    ///
    /// - Parameters:
    ///   - sepaData: The SEPA data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerSEPAAccount(sepaData: SEPAData, completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: sepaData, type: .sepa)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    /// Allow the user to select a payment method type and input its data from module-generated UI
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the payment method type selection should be presented
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerPaymentMethodUsingUI(on viewController: UIViewController, billingData: BillingData? = nil,
                                             completion: @escaping RegistrationResultCompletion) {
        let selectionViewController = PaymentMethodSelectionCollectionViewController()
        selectionViewController.selectablePaymentMethods = InternalPaymentSDK.sharedInstance.provider.supportedPaymentMethodTypeUserInterfaces

        func wrappedErrorCompletion(for dataProvider: PaymentMethodDataProvider?,
                                    completion: @escaping RegistrationResultCompletion) -> RegistrationResultCompletion {
            let wrapped: RegistrationResultCompletion = { result in
                switch result {
                case .success:
                    completion(result)
                case let .failure(error):
                    DispatchQueue.main.async {
                        dataProvider?.errorWhileCreatingPaymentMethod(error: error)
                    }

                    // The SDK user should not necessarily need to know about the specific errors that might happen but should
                    // get a high-level overview of what went wrong
                    #warning("Update this once errors are finalized")
                    let wrappedError = MLError(title: "Payment method UI error",
                                               description: error.errorDescription
                                                   ?? "An error occurred while the user was adding a payment method using the module UI",
                                               code: 107)
                    completion(.failure(wrappedError))
                }
            }
            return wrapped
        }

        selectionViewController.selectedPaymentMethodCallback = { selectedType in
            guard var paymentMethodViewController = InternalPaymentSDK.sharedInstance.provider
                .viewController(for: selectedType, billingData: billingData)
            else { fatalError("Payment method view controller for selected type not present in module") }

            paymentMethodViewController.didCreatePaymentMethodCompletion = { [weak self, weak paymentMethodViewController] method in
                if let creditCardData = method as? CreditCardData {
                    self?.registerCreditCard(creditCardData: creditCardData,
                                             completion: wrappedErrorCompletion(for: paymentMethodViewController, completion: completion))
                } else if let sepaData = method as? SEPAData {
                    self?.registerSEPAAccount(sepaData: sepaData,
                                              completion: wrappedErrorCompletion(for: paymentMethodViewController, completion: completion))
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
