//
//  InternalPaymentSDK.swift
//  MobilabPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

enum SDKError: Error {
    case providerNotSupportingPaymentMethod(providerName: String)

    func description() -> String {
        switch self {
        case let .providerNotSupportingPaymentMethod(name):
            return "Provider \(name) does not support registered payment method types"
        }
    }
}

class InternalPaymentSDK {
    private var wasInitialized = false

    private var _configuration: MobilabPaymentConfiguration?
    var configuration: MobilabPaymentConfiguration {
        guard let config = self._configuration else {
            fatalError(SDKConfigurationError.configurationMissing.description)
        }
        return config
    }

    private var _networkingClient: NetworkClientCore?
    var networkingClient: NetworkClientCore {
        guard let client = self._networkingClient else {
            fatalError(SDKConfigurationError.clientMissing.description)
        }
        return client
    }

    let pspCoordinator = InternalPaymentServiceProviderCoordinator()
    private(set) var uiConfiguration = PaymentMethodUIConfiguration()

    static let sharedInstance = InternalPaymentSDK()

    func initialize(configuration: MobilabPaymentConfiguration) {
        guard !wasInitialized
        else { fatalError("The MobilabPaymentSDK should only ever be initialized once!") }

        do {
            let url = try configuration.endpointUrl()
            self._networkingClient = NetworkClientCore(url: url)
            self._configuration = configuration
        } catch let error as MobilabPaymentError {
            fatalError(error.description)
        } catch {
            fatalError()
        }

        self.pspCoordinator.register(integrations: configuration.integrations)

        self.wasInitialized = true

        guard let uiConfiguration = configuration.uiConfiguration
        else { return }
        self.configureUI(configuration: uiConfiguration)
    }

    func configureUI(configuration: PaymentMethodUIConfiguration) {
        self.uiConfiguration = configuration
    }

    func registrationManager() -> InternalRegistrationManager {
        return InternalRegistrationManager()
    }

    func getAvailablePaymentMethodTypes() -> Set<PaymentMethodType> {
        return self.pspCoordinator.getSupportedPaymentMethodTypes()
    }

    func resetInitialization() {
        self.wasInitialized = false
    }
}
