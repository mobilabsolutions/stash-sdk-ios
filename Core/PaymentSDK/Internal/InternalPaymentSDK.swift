//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

enum SDKError: Error {
    case configurationMissing
    case clientMissing
    case providerMissing
    case providerNotSupportingPaymentMethod(providerName: String)

    func description() -> String {
        switch self {
        case .configurationMissing:
            return "SDK configuration is missing"
        case .clientMissing:
            return "SDK network client is missing"
        case .providerMissing:
            return "SDK Provider to found. Please add default provider"
        case let .providerNotSupportingPaymentMethod(name):
            return "Provider \(name) does not support registered payment method types"
        }
    }
}

class InternalPaymentSDK {
    private var _configuration: MobilabPaymentConfiguration?
    var configuration: MobilabPaymentConfiguration {
        guard let config = self._configuration else {
            fatalError(SDKError.configurationMissing.description())
        }
        return config
    }

    private var _networkingClient: NetworkClientCore?
    var networkingClient: NetworkClientCore {
        guard let client = self._networkingClient else {
            fatalError(SDKError.clientMissing.description())
        }
        return client
    }

    let pspCoordinator = InternalPaymentServiceProviderCoordinator()
    private(set) var uiConfiguration = PaymentMethodUIConfiguration()

    static let sharedInstance = InternalPaymentSDK()

    func configure(configuration: MobilabPaymentConfiguration) {
        do {
            let url = try configuration.endpointUrl()
            self._networkingClient = NetworkClientCore(url: url)
            self._configuration = configuration
        } catch let error as ConfigurationError {
            fatalError(error.description())
        } catch {
            fatalError()
        }
    }

    func configureUI(configuration: PaymentMethodUIConfiguration) {
        self.uiConfiguration = configuration
    }

    func registerProvider(provider: PaymentServiceProvider, forPaymentMethodTypes paymentMethodTypes: [PaymentMethodType]) {
        self.pspCoordinator.registerProvider(provider: provider, forPaymentMethodTypes: paymentMethodTypes)
    }

    func registrationManager() -> InternalRegistrationManager {
        return InternalRegistrationManager()
    }
}
