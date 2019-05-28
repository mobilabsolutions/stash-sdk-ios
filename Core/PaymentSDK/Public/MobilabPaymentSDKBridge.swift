//
//  MobilabPaymentSDKBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

@objc(MLMobilabPaymentSDK) public class MobilabPaymentSDKBridge: NSObject {
    @objc public static func initialize(configuration: MobilabPaymentConfiguration) {
        MobilabPaymentSDK.initialize(configuration: configuration)
    }

    @objc public static func configureUI(configuration: MLPaymentMethodUIConfiguration) {
        MobilabPaymentSDK.configureUI(configuration: configuration.configuration)
    }

    @objc public static func getRegistrationManager() -> RegistrationManagerBridge {
        return RegistrationManagerBridge(manager: MobilabPaymentSDK.getRegistrationManager())
    }

    @objc(MLPaymentMethodUIConfiguration) public class MLPaymentMethodUIConfiguration: NSObject {
        let configuration: PaymentMethodUIConfiguration

        /// Initialize the payment method UI configuration
        ///
        /// - Parameters:
        ///   - backgroundColor: The background color to use in the UI or `nil` for the default value
        ///   - textColor: The font color to use in the UI or `nil` for the default value
        ///   - buttonColor: The button color to use for enabled buttons in the UI or `nil` for the default value
        ///   - mediumEmphasisColor: The color to use for subtitles and other UI elements requiring medium emphasis
        ///                          or `nil` for the default value
        ///   - cellBackgroundColor: The background color to use for cells in the UI or `nil` for the default value
        ///   - buttonTextColor: The button text color to use in the UI or `nil` for the default value
        ///   - buttonDisabledColor: The button color to use when a button is disabled in the UI or `nil` for the default value
        @objc public required init(backgroundColor: UIColor?,
                                   textColor: UIColor?,
                                   buttonColor: UIColor?,
                                   mediumEmphasisColor: UIColor?,
                                   cellBackgroundColor: UIColor?,
                                   buttonTextColor: UIColor?,
                                   buttonDisabledColor: UIColor?,
                                   errorMessageColor: UIColor?,
                                   errorMessageTextColor: UIColor?) {
            self.configuration = PaymentMethodUIConfiguration(backgroundColor: backgroundColor,
                                                              textColor: textColor,
                                                              buttonColor: buttonColor,
                                                              mediumEmphasisColor: mediumEmphasisColor,
                                                              cellBackgroundColor: cellBackgroundColor,
                                                              buttonTextColor: buttonTextColor,
                                                              buttonDisabledColor: buttonDisabledColor,
                                                              errorMessageColor: errorMessageColor,
                                                              errorMessageTextColor: errorMessageTextColor)
        }

        init(configuration: PaymentMethodUIConfiguration) {
            self.configuration = configuration
        }
    }

    @objc(MLPaymentProviderIntegration) public class PaymentProviderIntegrationBridge: NSObject {
        let integration: PaymentProviderIntegration

        @objc public init?(paymentServiceProvider: Any, paymentMethodTypes: Set<Int>) {
            guard let provider = paymentServiceProvider as? PaymentServiceProvider
            else { fatalError("Provided Payment Provider is not a payment provider.") }

            let paymentMethods = paymentMethodTypes.map({ (method) -> PaymentMethodType in
                guard let bridgeType = RegistrationManagerBridge.PaymentMethodTypeBridge(rawValue: method),
                    let type = bridgeType.paymentMethodType
                else { fatalError("Provided value (\(method)) does not correspond to a payment method") }
                return type
            })

            guard let integration = PaymentProviderIntegration(paymentServiceProvider: provider, paymentMethodTypes: Set(paymentMethods))
            else { return nil }

            self.integration = integration
        }

        @objc public init(paymentServiceProvider: Any) {
            guard let provider = paymentServiceProvider as? PaymentServiceProvider
            else { fatalError("Provided Payment Provider is not a payment provider.") }

            self.integration = PaymentProviderIntegration(paymentServiceProvider: provider)
        }
    }
}

@objc(MLRegistrationManager) public class RegistrationManagerBridge: NSObject {
    private let manager: RegistrationManager

    init(manager: RegistrationManager) {
        self.manager = manager
    }

    @objc(MLCreditCardData) public class CreditCardDataBridge: NSObject, CreditCardDataInitializible {
        let creditCardData: CreditCardData

        @objc public required init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, country: String?, billingData: BillingData) throws {
            self.creditCardData = try CreditCardData(cardNumber: cardNumber,
                                                     cvv: cvv,
                                                     expiryMonth: expiryMonth,
                                                     expiryYear: expiryYear,
                                                     country: country,
                                                     billingData: billingData)
        }
    }

    @objc(MLSEPAData) public class SEPADataBridge: NSObject, SEPADataInitializible {
        let sepaData: SEPAData

        @objc public required init(iban: String, bic: String?, billingData: BillingData) throws {
            self.sepaData = try SEPAData(iban: iban, bic: bic, billingData: billingData)
        }
    }

    @objc(MLRegistration) public class RegistrationBridge: NSObject {
        @objc public let alias: String?
        @objc public let paymentMethodType: String
        @objc public let humanReadableIdentifier: String?

        init(alias: String?, paymentMethodType: PaymentMethodType, humanReadableIdentifier: String?) {
            self.alias = alias
            self.paymentMethodType = paymentMethodType.rawValue
            self.humanReadableIdentifier = humanReadableIdentifier
        }
    }

    @objc(MLError) public class MobilabPaymentErrorBridge: NSObject {
        @objc public let title: String
        @objc public let errorDescription: String

        public init(mobilabPaymentError: MobilabPaymentError) {
            self.title = mobilabPaymentError.title
            self.errorDescription = mobilabPaymentError.description
            super.init()
        }
    }

    @objc(MLPaymentMethodType) public enum PaymentMethodTypeBridge: Int {
        case none = 0
        case creditCard
        case payPal
        case sepa

        fileprivate var paymentMethodType: PaymentMethodType? {
            switch self {
            case .none: return nil
            case .creditCard: return .creditCard
            case .payPal: return .payPal
            case .sepa: return .sepa
            }
        }
    }

    @objc public func registerCreditCard(creditCardData: CreditCardDataBridge, idempotencyKey: String, completion: @escaping (RegistrationBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData,
                                        idempotencyKey: idempotencyKey,
                                        completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, idempotencyKey: String, completion: @escaping (RegistrationBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData,
                                         idempotencyKey: idempotencyKey,
                                         completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                                   specificPaymentMethod: PaymentMethodTypeBridge,
                                                   billingData _: BillingData?,
                                                   idempotencyKey: String,
                                                   completion: @escaping (RegistrationBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerPaymentMethodUsingUI(on: viewController,
                                                  specificPaymentMethod: specificPaymentMethod.paymentMethodType,
                                                  idempotencyKey: idempotencyKey,
                                                  completion: self.bridgedCompletion(completion: completion))
    }

    private func bridgedCompletion(completion: @escaping (RegistrationBridge?, MobilabPaymentErrorBridge?) -> Void) -> RegistrationResultCompletion {
        let bridged: ((RegistrationResult) -> Void) = { result in
            switch result {
            case let .success(registration):
                let bridgedRegistration = RegistrationBridge(alias: registration.alias, paymentMethodType: registration.paymentMethodType,
                                                             humanReadableIdentifier: registration.humanReadableIdentifier)
                completion(bridgedRegistration, nil)
            case let .failure(error): completion(nil, MobilabPaymentErrorBridge(mobilabPaymentError: error))
            }
        }

        return bridged
    }
}
