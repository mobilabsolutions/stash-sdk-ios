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
        MobilabPaymentSDK.configure(configuration: configuration)
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
}

@objc(MLRegistrationManager) public class RegistrationManagerBridge: NSObject {
    private let manager: RegistrationManager

    init(manager: RegistrationManager) {
        self.manager = manager
    }

    @objc(MLCreditCardData) public class CreditCardDataBridge: NSObject, CreditCardDataInitializible {
        let creditCardData: CreditCardData

        @objc public required init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String?, billingData: BillingData) throws {
            self.creditCardData = try CreditCardData(cardNumber: cardNumber, cvv: cvv,
                                                     expiryMonth: expiryMonth, expiryYear: expiryYear,
                                                     holderName: holderName, billingData: billingData)
        }
    }

    @objc(MLSEPAData) public class SEPADataBridge: NSObject, SEPADataInitializible {
        let sepaData: SEPAData

        @objc public required init(iban: String, bic: String, billingData: BillingData) throws {
            self.sepaData = try SEPAData(iban: iban, bic: bic, billingData: billingData)
        }
    }

    @objc public func registerCreditCard(creditCardData: CreditCardDataBridge, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData, completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData, completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPayPalAccount(presentingViewController viewController: UIViewController, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerPayPal(presentingViewController: viewController, completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerPaymentMethodUsingUI(on: viewController, completion: self.bridgedCompletion(completion: completion))
    }

    private func bridgedCompletion(completion: @escaping (String?, MLError?) -> Void) -> RegistrationResultCompletion {
        let bridged: ((RegistrationResult) -> Void) = { result in
            switch result {
            case let .success(alias): completion(alias, nil)
            case let .failure(error): completion(nil, error)
            }
        }

        return bridged
    }
}
