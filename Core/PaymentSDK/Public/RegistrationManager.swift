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
    /// Register a credit card
    ///
    /// - Parameters:
    ///   - creditCardData: The credit card data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerCreditCard(creditCardData: CreditCardData,
                                   idempotencyKey: String = UUID().uuidString,
                                   completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: creditCardData, type: .creditCard)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, idempotencyKey: idempotencyKey, completion: completion)
    }

    /// Register a SEPA account
    ///
    /// - Parameters:
    ///   - sepaData: The SEPA data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerSEPAAccount(sepaData: SEPAData,
                                    idempotencyKey: String = UUID().uuidString,
                                    completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: sepaData, type: .sepa)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, idempotencyKey: idempotencyKey, completion: completion)
    }

    /// Starts the flow for PayPal registration
    ///
    /// - Parameters:
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method

    public func registerPayPal(presentingViewController: UIViewController,
                               idempotencyKey: String = UUID().uuidString,
                               completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: PayPalData(nonce: nil), type: .payPal)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, idempotencyKey: idempotencyKey, completion: completion, presentingViewController: presentingViewController)
    }

    /// Allow the user to select a payment method type and input its data from module-generated UI
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the payment method type selection should be presented
    ///   - billingData: The billing data that should be prefilled when registering the payment method
    ///   - mobilabProvider: Provider to use for credit card and SEPA
    ///   - mobilabPayPalProvider: Provider to use for PayPal
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                             billingData: BillingData? = nil,
                                             completion: @escaping RegistrationResultCompletion) {
        let uiConfiguration = InternalPaymentSDK.sharedInstance.uiConfiguration
        let selectionViewController = PaymentMethodSelectionCollectionViewController(configuration: uiConfiguration)

        func wrappedCompletion(for dataProvider: PaymentMethodDataProvider?,
                               completion: @escaping RegistrationResultCompletion) -> RegistrationResultCompletion {
            let wrapped: RegistrationResultCompletion = { result in
                switch result {
                case .success:
                    completion(result)
                case let .failure(error):
                    DispatchQueue.main.async {
                        dataProvider?.errorWhileCreatingPaymentMethod(error: error)
                    }
                    completion(.failure(error))
                }
            }
            return wrapped
        }

        let methods = InternalPaymentSDK.sharedInstance.pspCoordinator
            .getSupportedPaymentMethodTypeUserInterfaces()
        selectionViewController.setSelectablePaymentMethods(methods: methods)

        selectionViewController.selectedPaymentMethodCallback = { selectedType in
            let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: selectedType.internalPaymentMethodType)
            guard var paymentMethodViewController = provider.viewController(for: selectedType, billingData: billingData,
                                                                            configuration: uiConfiguration)
            else { fatalError("Payment method view controller for selected type not present in module") }
            paymentMethodViewController.didCreatePaymentMethodCompletion = { [weak self, weak paymentMethodViewController] method in
                if let creditCardData = method as? CreditCardData {
                    self?.registerCreditCard(creditCardData: creditCardData,
                                             completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
                } else if let sepaData = method as? SEPAData {
                    self?.registerSEPAAccount(sepaData: sepaData,
                                              completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
                } else if method is PayPalData {
                    self?.registerPayPal(presentingViewController: viewController, completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
                } else {
                    fatalError("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData, CreditCardData or PayPalData")
                }
            }

            selectionViewController.navigationController?.pushViewController(paymentMethodViewController, animated: true)
        }

        let navigationController = RegistrationFlowNavigationController(rootViewController: selectionViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }
}
