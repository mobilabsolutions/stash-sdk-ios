//
//  RegistrationManager.swift
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
    ///   - idempotencyKey: The idempotency key that should be used for this request. The same idempotency key always results in the same returned result.
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerCreditCard(creditCardData: CreditCardData,
                                   idempotencyKey: String = UUID().uuidString,
                                   completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: creditCardData, type: .creditCard)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod,
                                  idempotencyKey: idempotencyKey,
                                  completion: completion,
                                  methodType: .creditCard)
    }

    /// Register a SEPA account
    ///
    /// - Parameters:
    ///   - sepaData: The SEPA data to use for registration
    ///   - idempotencyKey: The idempotency key that should be used for this request. The same idempotency key always results in the same returned result.
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerSEPAAccount(sepaData: SEPAData,
                                    idempotencyKey: String = UUID().uuidString,
                                    completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: sepaData, type: .sepa)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod,
                                  idempotencyKey: idempotencyKey,
                                  completion: completion,
                                  methodType: .sepa)
    }

    /// Starts the flow for PayPal registration
    ///
    /// - Parameters:
    ///   - presentingViewController: The view controller that the PayPal UI should be presented on top of
    ///   - billingData: The billing data that should be prefilled when registering the payment method
    ///   - idempotencyKey: The idempotency key that should be used for this request. The same idempotency key always results in the same returned result.
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerPayPal(presentingViewController: UIViewController,
                               billingData: BillingData?,
                               idempotencyKey: String = UUID().uuidString,
                               completion: @escaping RegistrationResultCompletion) {
        let paymentMethod = PaymentMethod(methodData: PayPalPlaceholderData(billingData: billingData), type: .payPal)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod,
                                  idempotencyKey: idempotencyKey,
                                  completion: completion,
                                  presentingViewController: presentingViewController,
                                  methodType: .payPal)
    }

    /// Allow the user to select a payment method type and input its data from module-generated UI
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the payment method type selection should be presented
    ///   - specificPaymentMethod: The specific payment method type for which registration should be performed.
    ///                            By default nil, and the user is presented with a picker to chose one of the available payment method types.
    ///   - billingData: The billing data that should be prefilled when registering the payment method
    ///   - idempotencyKey: The idempotency key that should be used for this request. The same idempotency key always results in the same returned result.
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                             specificPaymentMethod: PaymentMethodType? = nil,
                                             billingData: BillingData? = nil,
                                             idempotencyKey: String = UUID().uuidString,
                                             completion: @escaping RegistrationResultCompletion) {
        let uiConfiguration = InternalPaymentSDK.sharedInstance.uiConfiguration

        let rootViewController: UIViewController

        if let specificPaymentMethod = specificPaymentMethod {
            // A specific payment method was provided, we do not need the user to chose one and therefore directly show the
            // view controller for that payment method.
            rootViewController = self.paymentViewController(for: specificPaymentMethod,
                                                            billingData: billingData,
                                                            uiConfiguration: uiConfiguration,
                                                            idempotencyKey: idempotencyKey,
                                                            completion: completion)
        } else {
            // The user needs to chose a payment method to use, therefore we show the selection view controller
            let methods = InternalPaymentSDK.sharedInstance.pspCoordinator
                .getSupportedPaymentMethodTypeUserInterfaces()
            let selectionViewController = self.selectionViewController(for: methods, uiConfiguration: uiConfiguration)
            selectionViewController.selectedPaymentMethodCallback = { selectedType in
                let paymentMethodViewController = self.paymentViewController(for: selectedType,
                                                                             billingData: billingData,
                                                                             uiConfiguration: uiConfiguration,
                                                                             idempotencyKey: idempotencyKey,
                                                                             completion: completion)
                selectionViewController.navigationController?.pushViewController(paymentMethodViewController, animated: true)
            }

            rootViewController = selectionViewController
        }

        let navigationController = RegistrationFlowNavigationController(rootViewController: rootViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }

    private func selectionViewController(for paymentMethods: Set<PaymentMethodType>, uiConfiguration: PaymentMethodUIConfiguration) -> PaymentMethodSelectionCollectionViewController {
        let selectionViewController = PaymentMethodSelectionCollectionViewController(configuration: uiConfiguration)
        selectionViewController.setSelectablePaymentMethods(methods: paymentMethods)
        return selectionViewController
    }

    private func paymentViewController(for type: PaymentMethodType,
                                       billingData: BillingData?,
                                       uiConfiguration: PaymentMethodUIConfiguration,
                                       idempotencyKey: String,
                                       completion: @escaping RegistrationResultCompletion) -> UIViewController & PaymentMethodDataProvider {
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

        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: type.internalPaymentMethodType)
        guard var paymentMethodViewController = provider.viewController(for: type, billingData: billingData,
                                                                        configuration: uiConfiguration)
        else { fatalError("Payment method view controller for selected type not present in module") }

        paymentMethodViewController.didCreatePaymentMethodCompletion = { [unowned paymentMethodViewController] method in
            if let creditCardData = method as? CreditCardData {
                self.registerCreditCard(creditCardData: creditCardData,
                                        idempotencyKey: idempotencyKey,
                                        completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
            } else if let sepaData = method as? SEPAData {
                self.registerSEPAAccount(sepaData: sepaData,
                                         idempotencyKey: idempotencyKey,
                                         completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
            } else if method is PayPalPlaceholderData {
                self.registerPayPal(presentingViewController: paymentMethodViewController,
                                    billingData: billingData,
                                    idempotencyKey: idempotencyKey,
                                    completion: wrappedCompletion(for: paymentMethodViewController, completion: completion))
            } else {
                fatalError("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData, CreditCardData or PayPalData")
            }
        }

        return paymentMethodViewController
    }
}
