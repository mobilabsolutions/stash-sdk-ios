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

    @objc public static func addProvider(provider: Any) {
        guard let provider = provider as? PaymentServiceProvider
        else { fatalError("Provided Payment Provider is not a payment provider.") }
        InternalPaymentSDK.sharedInstance.addProvider(provider: provider)
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
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData,
                                        completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData, completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                                   completion: @escaping (String?, MLError?) -> Void) {
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
