//
//  PaymentMethodTypeProviderCoordinator.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 21/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class PaymentServiceProviderCoordinator {
    private var store = [InternalPaymentMethodType: PaymentServiceProvider]()
    private var providers = [PaymentServiceProvider]()

    func registerProvider(provider: PaymentServiceProvider, forPaymentMethodTypes paymentMethodTypes: [PaymentMethodType]) {
        let providerSupportedPaymentMethodTypes = Set(provider.supportedPaymentMethodTypes.map({ $0.hashValue }))
        let paymentMethodTypesToRegister = Set(paymentMethodTypes.map({ $0.hashValue }))

        guard paymentMethodTypesToRegister.subtracting(providerSupportedPaymentMethodTypes).count == 0 else {
            fatalError(SDKError.providerNotSupportingPaymentMethod(providerName: provider.pspIdentifier.rawValue).description())
        }

        self.providers.append(provider)
        for (_, element) in paymentMethodTypes.enumerated() {
            self.store[element.internalPaymentMethodType] = provider
        }
    }

    func getProvider(forPaymentMethodType paymentMethodType: InternalPaymentMethodType) -> PaymentServiceProvider {
        guard let defaultProvider = self.providers.first else {
            fatalError(SDKError.providerMissing.description())
        }

        if let registeredProvider = self.store[paymentMethodType] {
            return registeredProvider
        } else {
            return defaultProvider
        }
    }

    func getSupportedPaymentMethodTypes() -> [PaymentMethodType] {
        return self.providers.flatMap { $0.supportedPaymentMethodTypes }
    }

    func getSupportedPaymentMethodTypeUserInterfaces() -> [PaymentMethodType] {
        return self.providers.flatMap { $0.supportedPaymentMethodTypeUserInterfaces }
    }
}
