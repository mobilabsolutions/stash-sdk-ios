//
//  MobilabPaymentSDKBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

@objc(MLMobilabPaymentSDK) public class MobilabPaymentSDKBridge: NSObject {
    @objc public static func configure(configuration: MobilabPaymentConfiguration) {
        MobilabPaymentSDK.initialize(configuration: configuration)
    }

    @objc public static func configureUI(configuration: MLPaymentMethodUIConfiguration) {
        MobilabPaymentSDK.configureUI(configuration: configuration.configuration)
    }

    @objc public static func getRegistrationManager() -> RegistrationManagerBridge {
        return RegistrationManagerBridge(manager: MobilabPaymentSDK.getRegistrationManager())
    }

    @objc public static func registerProvider(provider: Any, paymentMethods: [Any]) {
        guard let provider = provider as? PaymentServiceProvider
        else { fatalError("Provided Payment Provider is not a payment provider.") }
        guard paymentMethods.count != 0
        else { fatalError("Provide at least one payment method when registering a provider") }

        let paymentMethods = paymentMethods.map({ (method) -> PaymentMethodType in
            guard let method = method as? String
            else { fatalError("Provided Payment method type is not a string") }
            guard let type = PaymentMethodType(rawValue: method)
            else { fatalError("Provided Payment Provider is not a payment provider.") }
            return type
        })

        InternalPaymentSDK.sharedInstance.registerProvider(provider: provider, forPaymentMethodTypes: paymentMethods)
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
}

@objc(MLRegistrationManager) public class RegistrationManagerBridge: NSObject {
    private let manager: RegistrationManager

    init(manager: RegistrationManager) {
        self.manager = manager
    }

    @objc(MLCreditCardData) public class CreditCardDataBridge: NSObject, CreditCardDataInitializible {
        let creditCardData: CreditCardData

        @objc public required init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String?, country: String?, billingData: BillingData) throws {
            self.creditCardData = try CreditCardData(cardNumber: cardNumber, cvv: cvv,
                                                     expiryMonth: expiryMonth, expiryYear: expiryYear,
                                                     holderName: holderName, country: country, billingData: billingData)
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
        let title: String
        let errorDescription: String

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
