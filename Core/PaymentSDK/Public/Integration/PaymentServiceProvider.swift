//
import MobilabPaymentUI
//  PSPIntegrationProtocol.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//
import UIKit

public enum MobilabPaymentProvider: String {
    case bsPayone = "BS_PAYONE"
    case braintree = "BRAINTREE"
}

/// A protocol representing the behaviour a payment service provider (PSP) module should provide
public protocol PaymentServiceProvider {
    /// A result obtained from registering a payment method with the PSP
    typealias RegistrationResult = NetworkClientResult<String?, MLError>
    typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

    /// The PSP identifier as required by the Mobilab payment backend
    var pspIdentifier: MobilabPaymentProvider { get }

    #warning("Document the PSP public key or remove it if it is not necessary")
    var publicKey: String { get }

    /// Handle a request for registering a payment method with the PSP
    ///
    /// - Parameters:
    ///   - registrationRequest: the registration request data
    ///   - completion: A completion returning the generated PSP alias (if present) or an error
    func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping RegistrationResultCompletion)

    /// All payment method types which module supports
    var supportedPaymentMethodTypes: [PaymentMethodType] { get }

    /// All payment method types for which the module provides user interface means of creating the data
    var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] { get }

    /// Create a view controller allowing input of data for a given payment method type
    ///
    /// - Parameters:
    ///   - paymentMethodType: The payment method type for which to create the UI. Is one of `supportedPaymentMethodTypeUserInterfaces`
    ///   - billingData: The billing data to prefill (if necessary)
    ///   - configuration: The UI configuration to apply
    /// - Returns: A view controller for inputting the data relevant to the payment method type
    func viewController(for paymentMethodType: PaymentMethodType,
                        billingData: BillingData?,
                        configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)?
}

public extension PaymentServiceProvider {
    var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return []
    }

    func viewController(for _: PaymentMethodType, billingData _: BillingData?, configuration _: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        return nil
    }
}
