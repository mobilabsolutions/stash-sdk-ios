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
    ///   - mobilabProvider: Provider to use for credit card and SEPA
    ///   - creditCardData: The credit card data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerCreditCard(mobilabProvider: MobilabPaymentProvider, creditCardData: CreditCardData, completion: @escaping RegistrationResultCompletion) {
        InternalPaymentSDK.sharedInstance.setActiveProvider(mobilabProvider: mobilabProvider)
        let paymentMethod = PaymentMethod(methodData: creditCardData, type: .creditCard)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    /// Register a SEPA account
    ///
    /// - Parameters:
    ///   - mobilabProvider: Provider to use for credit card and SEPA
    ///   - sepaData: The SEPA data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerSEPAAccount(mobilabProvider: MobilabPaymentProvider, sepaData: SEPAData, completion: @escaping RegistrationResultCompletion) {
        InternalPaymentSDK.sharedInstance.setActiveProvider(mobilabProvider: mobilabProvider)
        let paymentMethod = PaymentMethod(methodData: sepaData, type: .sepa)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    private func registerPayPal(mobilabProvider: MobilabPaymentProvider, payPalData: PayPalData, completion: @escaping RegistrationResultCompletion) {
        InternalPaymentSDK.sharedInstance.setActiveProvider(mobilabProvider: mobilabProvider)
        let paymentMethod = PaymentMethod(methodData: payPalData, type: .payPal)

        let internalManager = InternalPaymentSDK.sharedInstance.registrationManager()
        internalManager.addMethod(paymentMethod: paymentMethod, completion: completion)
    }

    /// Starts the flow for PayPal registration
    ///
    /// - Parameters:
    ///   - mobilabProvider: Provider to use for credit card and SEPA
    ///   - sepaData: The SEPA data to use for registration
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func startPayPalRegistration(on viewController: UIViewController, mobilabProvider: MobilabPaymentProvider, completion: @escaping RegistrationResultCompletion) {
        InternalPaymentSDK.sharedInstance.setActiveProvider(mobilabProvider: mobilabProvider)
        guard var paymentMethodViewController = InternalPaymentSDK.sharedInstance.provider.viewController(for: .payPal)
        else { fatalError("Payment method view controller for selected type not present in module") }

        paymentMethodViewController.didCreatePaymentMethodCompletion = { [weak self] method in
            if let payPalData = method as? PayPalData {
                self!.registerPayPal(mobilabProvider: mobilabProvider, payPalData: payPalData, completion: completion)
            } else {
                print("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData or CreditCardData")
            }
        }

        let navigationController = RegistrationFlowNavigationController(rootViewController: paymentMethodViewController)
        viewController.present(navigationController, animated: true, completion: nil)
    }

    /// Allow the user to select a payment method type and input its data from module-generated UI
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the payment method type selection should be presented
    ///   - mobilabProvider: Provider to use for credit card and SEPA
    ///   - mobilabPayPalProvider: Provider to use for PayPal
    ///   - completion: A completion called when the registration is complete.
    ///                 Provides the Mobilab payment alias that identifies the registerd payment method
    public func registerPaymentMethodUsingUI(on viewController: UIViewController, mobilabProvider: MobilabPaymentProvider, mobilabPayPalProvider: MobilabPaymentProvider, completion: @escaping RegistrationResultCompletion) {
        let selectionViewController = PaymentMethodSelectionCollectionViewController()
        selectionViewController.selectablePaymentMethods = InternalPaymentSDK.sharedInstance.getSupportedPaymentMethodTypeUserInterfaces()
        selectionViewController.selectedPaymentMethodCallback = { selectedType in
            guard var paymentMethodViewController = InternalPaymentSDK.sharedInstance.provider.viewController(for: selectedType)
            else { fatalError("Payment method view controller for selected type not present in module") }

            paymentMethodViewController.didCreatePaymentMethodCompletion = { [weak self] method in
                if let creditCardData = method as? CreditCardData {
                    self?.registerCreditCard(mobilabProvider: mobilabProvider, creditCardData: creditCardData, completion: completion)
                } else if let sepaData = method as? SEPAData {
                    self?.registerSEPAAccount(mobilabProvider: mobilabProvider, sepaData: sepaData, completion: completion)
                } else if let payPalData = method as? PayPalData {
                    self?.registerPayPal(mobilabProvider: mobilabPayPalProvider, payPalData: payPalData, completion: completion)
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
