//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

private enum SDKError: Error {
    case configurationMissing
    case clientMissing
    case providerMissing

    func description() -> String {
        switch self {
        case .configurationMissing:
            return "SDK configuration is missing"
        case .clientMissing:
            return "SDK network client is missing"
        case .providerMissing:
            return "SDK Provider to found. Please add default provider"
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

    private var _providers = [PaymentServiceProvider]()
    private var _activeProvider: PaymentServiceProvider?
    var provider: PaymentServiceProvider {
        guard let provider = self._activeProvider else {
            fatalError(SDKError.providerMissing.description())
        }
        return provider
    }

    public func setActiveProvider(mobilabProvider: MobilabPaymentProvider) {
        if let provider = _providers.first(where: { $0.pspIdentifier == mobilabProvider }) {
            self._activeProvider = provider
        }
    }

    public func getSupportedPaymentMethodTypeUserInterfaces() -> [PaymentMethodType] {
        var supportedTypes = [PaymentMethodType]()
        for provider in self._providers {
            supportedTypes.append(contentsOf: provider.supportedPaymentMethodTypeUserInterfaces)
        }
        return supportedTypes
    }

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

    func addProvider(provider: PaymentServiceProvider) {
        self._providers.append(provider)
    }

    func registrationManager() -> InternalRegistrationManager {
        return InternalRegistrationManager()
    }
}
