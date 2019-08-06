//
//  RegistrationManagerObjCBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// A bridge that allows using the RegistrationManager from Objective-C
@objc(MLRegistrationManager) public class RegistrationManagerBridge: NSObject {
    private let manager: RegistrationManager

    init(manager: RegistrationManager) {
        self.manager = manager
    }

    /// Register a credit card payment method. For detailed information on the parameters, see the equivalent method documentation in `RegistrationManager`.
    @objc public func registerCreditCard(creditCardData: CreditCardDataBridge, idempotencyKey: String?, completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData,
                                        idempotencyKey: idempotencyKey,
                                        completion: self.bridgedCompletion(completion: completion))
    }

    /// Register a SEPA payment method. For detailed information on the parameters, see the equivalent method documentation in `RegistrationManager`.
    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, idempotencyKey: String?, completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData,
                                         idempotencyKey: idempotencyKey,
                                         completion: self.bridgedCompletion(completion: completion))
    }

    /// Register a payment method using the SDK-provided UI. For detailed information on the parameters, see the equivalent method documentation in `RegistrationManager`.
    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                                   specificPaymentMethod: PaymentMethodTypeBridge,
                                                   billingData: BillingData?,
                                                   completion: @escaping (PaymentMethodAliasBridge?, MobilabPaymentErrorBridge?) -> Void) {
        self.manager.registerPaymentMethodUsingUI(on: viewController,
                                                  specificPaymentMethod: specificPaymentMethod.paymentMethodType, billingData: billingData,
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
