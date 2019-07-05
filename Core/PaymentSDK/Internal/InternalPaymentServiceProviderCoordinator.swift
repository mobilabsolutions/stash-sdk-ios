//
//  InternalPaymentServiceProviderCoordinator.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 21/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

class InternalPaymentServiceProviderCoordinator {
    private var store = [InternalPaymentMethodType: PaymentServiceProvider]()
    private var providers = [PaymentServiceProvider]()

    func register(integrations: [PaymentProviderIntegration]) {
        for integration in integrations {
            let provider = integration.paymentServiceProvider
            let paymentMethodTypes = integration.paymentMethodTypes

            self.providers.append(provider)

            for element in paymentMethodTypes {
                guard self.store[element.internalPaymentMethodType] == nil
                else { fatalError("Only one payment service provider may be registered per payment method type!") }

                self.store[element.internalPaymentMethodType] = provider
            }
        }
    }

    func getProvider(forPaymentMethodType paymentMethodType: InternalPaymentMethodType) -> PaymentServiceProvider {
        guard let registeredProvider = self.store[paymentMethodType] else {
            fatalError(SDKConfigurationError.paymentMethodIsMissingProvider(paymentMethodType.rawValue).description)
        }

        return registeredProvider
    }

    func getSupportedPaymentMethodTypes() -> Set<PaymentMethodType> {
        return Set(self.store.keys.compactMap { $0.publicPaymentMethodType })
    }

    func getSupportedPaymentMethodTypeUserInterfaces() -> Set<PaymentMethodType> {
        return Set(self.providers.flatMap { $0.supportedPaymentMethodTypeUserInterfaces }).intersection(self.getSupportedPaymentMethodTypes())
    }

    func removeAllProviders() {
        self.store = [:]
        self.providers = []
    }
}
