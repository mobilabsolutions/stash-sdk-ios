//
//  PSPIntegrationProtocol.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// Supported payment providers
public enum StashPaymentProvider: String, Codable {
    /// BS Payone PSP
    case bsPayone = "BS_PAYONE"
    /// Braintree PSP
    case braintree = "BRAINTREE"
    /// Adyen PSP
    case adyen = "ADYEN"
}

/// A protocol representing the behaviour a payment service provider (PSP) module should provide
public protocol PaymentServiceProvider {
    /// A result obtained from registering a payment method with the PSP
    typealias RegistrationResult = Result<PSPRegistration, StashError>
    /// A completion callback that provides the created `RegistrationResult`
    typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)
    /// A completion callback that provides 3DS authentication result
    typealias ThreeDSAuthenticationCompletion = ((Result<ThreeDSResult, StashError>) -> Void)
    /// The PSP identifier as required by the Stash payment backend
    var pspIdentifier: StashPaymentProvider { get }

    /// Handle a request for registering a payment method with the PSP
    ///
    /// - Parameters:
    ///   - registrationRequest: the registration request data
    ///   - idempotencyKey: the request's user provided idempotency key that should be used to ensure idempotency of actions
    ///   - uniqueRegistrationIdentifier: An identifier that is unique across registrations and can be used to associate state to a given registration request
    ///   - completion: A completion returning the generated PSP alias (if present) or an error
    func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                   idempotencyKey: String?,
                                   uniqueRegistrationIdentifier: String,
                                   completion: @escaping RegistrationResultCompletion)

    /// Handle a 3DS1 or 3DS2 authentication request
    ///
    /// - Parameters:
    ///   - request: the 3DS2 request data
    ///   - completion: A completion returning the response from 3DS authentication (if present) or an error
    func handle3DS(request: ThreeDSRequest, viewController: UIViewController, completion: @escaping ThreeDSAuthenticationCompletion)

    /// Handle a request for registering a payment method with the PSP
    ///
    /// - Parameters:
    ///   - paymentMethodData: the payment method data that will be registered
    ///   - idempotencyKey: the request's user provided idempotency key that should be used to ensure idempotency of actions
    ///   - uniqueRegistrationIdentifier: An identifier that is unique across registrations and can be used to associate state to a given registration request
    ///   - completion: A completion returning the generated AliasCreationDetail (if necessary) or an error if something went wrong
    func provideAliasCreationDetail(for paymentMethodData: RegistrationData,
                                    idempotencyKey: String?,
                                    uniqueRegistrationIdentifier: String,
                                    completion: @escaping (Result<AliasCreationDetail?, StashError>) -> Void)

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
    func provideAliasCreationDetail(for _: RegistrationData,
                                    idempotencyKey _: String?,
                                    uniqueRegistrationIdentifier _: String,
                                    completion: @escaping (Result<AliasCreationDetail?, StashError>) -> Void) {
        completion(.success(nil))
    }

    func handle3DS(request _: ThreeDSRequest, viewController _: UIViewController, completion _: @escaping ThreeDSAuthenticationCompletion) {}

    var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return []
    }

    func viewController(for _: PaymentMethodType, billingData _: BillingData?, configuration _: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        return nil
    }
}
