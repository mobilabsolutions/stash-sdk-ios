//
//  PaymentMethodTypeProviderCoordinator.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 21/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class InternalPaymentServiceProviderCoordinator {
    private var store = [InternalPaymentMethodType: PaymentServiceProvider]()
    private var providers = [PaymentServiceProvider]()

    func registerProvider(provider: PaymentServiceProvider, forPaymentMethodTypes paymentMethodTypes: [PaymentMethodType]) {
        let providerSupportedPaymentMethodTypes = Set(provider.supportedPaymentMethodTypes.map({ $0.hashValue }))
        let paymentMethodTypesToRegister = Set(paymentMethodTypes.map({ $0.hashValue }))

        guard paymentMethodTypesToRegister.subtracting(providerSupportedPaymentMethodTypes).count == 0 else {
            fatalError(SDKConfigurationError.providerNotSupportingPaymentMethod(provider: provider.pspIdentifier.rawValue,
                                                                                paymentMethod: "\(paymentMethodTypes)").description)
        }

        self.providers.append(provider)

        for element in paymentMethodTypes {
            self.store[element.internalPaymentMethodType] = provider
        }
    }

    func getProvider(forPaymentMethodType paymentMethodType: InternalPaymentMethodType) -> PaymentServiceProvider {
        guard let defaultProvider = self.providers.first else {
            fatalError(SDKConfigurationError.paymentMethodIsMissingProvider(paymentMethodType.rawValue).description)
        }

        if let registeredProvider = self.store[paymentMethodType] {
            return registeredProvider
        } else {
            return defaultProvider
        }
    }

    func getSupportedPaymentMethodTypes() -> Set<PaymentMethodType> {
        return Set(self.providers.flatMap { $0.supportedPaymentMethodTypes })
    }

    func getSupportedPaymentMethodTypeUserInterfaces() -> Set<PaymentMethodType> {
        return Set(self.providers.flatMap { $0.supportedPaymentMethodTypeUserInterfaces })
    }

    func removeAllProviders() {
        self.store = [:]
        self.providers = []
    }
}
