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

        @objc public init?(paymentServiceProvider bridge: PaymentProviderBridge, paymentMethodTypes: Set<Int>) {
            let paymentMethods = paymentMethodTypes.map({ (method) -> PaymentMethodType in
                guard let bridgeType = RegistrationManagerBridge.PaymentMethodTypeBridge(rawValue: method),
                    let type = bridgeType.paymentMethodType
                else { fatalError("Provided value (\(method)) does not correspond to a payment method") }
                return type
            })

            guard let integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider,
                                                               paymentMethodTypes: Set(paymentMethods))
            else { return nil }

            self.integration = integration
        }

        @objc public init(paymentServiceProvider bridge: PaymentProviderBridge) {
            self.integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider)
        }
    }

    @objc(MLPaymentProvider) public final class PaymentProviderBridge: NSObject {
        let paymentProvider: PaymentServiceProvider

        public init(paymentProvider: PaymentServiceProvider) {
            self.paymentProvider = paymentProvider
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

    @objc(MLPaymentMethodAlias) public class PaymentMethodAliasBridge: NSObject {
        @objc public let alias: String?
        @objc public let paymentMethodType: String
        @objc public let extraAliasInfo: ExtraAliasInfoBridge

        @objc(MLExtraAliasInfo) public class ExtraAliasInfoBridge: NSObject {
            @objc public let creditCardExtraInfo: CreditCardExtraInfoBridge?
            @objc public let sepaExtraInfo: SEPAExtraInfoBridge?
            @objc public let payPalExtraInfo: PayPalExtraInfoBridge?

            init(creditCardExtraInfo: CreditCardExtraInfoBridge?, sepaExtraInfo: SEPAExtraInfoBridge?, payPalExtraInfo: PayPalExtraInfoBridge?) {
                self.creditCardExtraInfo = creditCardExtraInfo
                self.sepaExtraInfo = sepaExtraInfo
                self.payPalExtraInfo = payPalExtraInfo
            }

            @objc(MLCreditCardExtraInfo) public class CreditCardExtraInfoBridge: NSObject {
                @objc public let creditCardMask: String
                @objc public let expiryMonth: Int
                @objc public let expiryYear: Int
                @objc public let creditCardType: String

                init(creditCardMask: String, expiryMonth: Int, expiryYear: Int, creditCardType: String) {
                    self.creditCardMask = creditCardMask
                    self.expiryMonth = expiryMonth
                    self.expiryYear = expiryYear
                    self.creditCardType = creditCardType
                }
            }

            @objc(MLSEPAExtraInfo) public class SEPAExtraInfoBridge: NSObject {
                @objc public let maskedIban: String

                init(maskedIban: String) {
                    self.maskedIban = maskedIban
                }
            }

            @objc(MLPayPalExtraInfo) public class PayPalExtraInfoBridge: NSObject {
                @objc public let email: String?

                init(email: String?) {
                    self.email = email
                }
            }
        }

        init(alias: String?, paymentMethodType: PaymentMethodType, extraAliasInfo: ExtraAliasInfoBridge) {
            self.alias = alias
            self.paymentMethodType = paymentMethodType.rawValue
            self.extraAliasInfo = extraAliasInfo
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

    @objc public func registerCreditCard(creditCardData: CreditCardDataBridge, idempotencyKey: String?, completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData,
                                        idempotencyKey: idempotencyKey,
                                        completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, idempotencyKey: String?, completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData,
                                         idempotencyKey: idempotencyKey,
                                         completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                                   specificPaymentMethod: PaymentMethodTypeBridge,
                                                   billingData _: BillingData?,
                                                   idempotencyKey: String?,
                                                   completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerPaymentMethodUsingUI(on: viewController,
                                                  specificPaymentMethod: specificPaymentMethod.paymentMethodType,
                                                  idempotencyKey: idempotencyKey,
                                                  completion: self.bridgedCompletion(completion: completion))
    }

    private func bridgedCompletion(completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) -> RegistrationResultCompletion {
        let bridged: ((RegistrationResult) -> Void) = { result in
            switch result {
            case let .success(registration):
                let bridgedRegistration = PaymentMethodAliasBridge(alias: registration.alias,
                                                                   paymentMethodType: registration.paymentMethodType,
                                                                   extraAliasInfo: registration.extraAliasInfo.bridgedAliasInfo)
                completion(bridgedRegistration, nil)
            case let .failure(error): completion(nil, MobilabPaymentErrorBridge(mobilabPaymentError: error))
            }
        }

        return bridged
    }
}

private extension PaymentMethodAlias.ExtraAliasInfo {
    var bridgedAliasInfo: RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge {
        switch self {
        case let .creditCard(details):
            return RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: details.bridgedExtraInfo,
                                                                                           sepaExtraInfo: nil,
                                                                                           payPalExtraInfo: nil)
        case let .sepa(details):
            return RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: nil,
                                                                                           sepaExtraInfo: details.bridgedExtraInfo,
                                                                                           payPalExtraInfo: nil)
        case let .payPal(details):
            return RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge(creditCardExtraInfo: nil,
                                                                                           sepaExtraInfo: nil,
                                                                                           payPalExtraInfo: details.bridgedExtraInfo)
        }
    }
}

private extension PaymentMethodAlias.CreditCardExtraInfo {
    typealias Bridge = RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge.CreditCardExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(creditCardMask: self.creditCardMask,
                      expiryMonth: self.expiryMonth,
                      expiryYear: self.expiryYear,
                      creditCardType: self.creditCardType.rawValue)
    }
}

private extension PaymentMethodAlias.SEPAExtraInfo {
    typealias Bridge = RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge.SEPAExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(maskedIban: self.maskedIban)
    }
}

private extension PaymentMethodAlias.PayPalExtraInfo {
    typealias Bridge = RegistrationManagerBridge.PaymentMethodAliasBridge.ExtraAliasInfoBridge.PayPalExtraInfoBridge

    var bridgedExtraInfo: Bridge {
        return Bridge(email: self.email)
    }
}
