//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

private enum ConfigurationError: Error {
    case publicKeyNotSet
    case endpointNotSet
    case providerNotSet

    func description() -> String {
        switch self {
        case .publicKeyNotSet:
            return "SDK Public key is not set!"
        case .endpointNotSet:
            return "SDK Endpoint is not set"
        case .providerNotSet:
            return "No Provider found. Please add default provider"
        }
    }
}

class InternalPaymentSDK {
    var networkingClient: NetworkClientCore
    var provider: PaymentServiceProvider?
    var configuration: MobilabPaymentConfiguration

    private init() {
        self.networkingClient = NetworkClientCore()
        self.configuration = MobilabPaymentConfiguration()
    }

    private func isSDKConfigured() throws -> Bool {
        guard !self.configuration.publicKey.isEmpty else {
            throw ConfigurationError.publicKeyNotSet
        }

        guard !self.configuration.endpoint.isEmpty else {
            throw ConfigurationError.endpointNotSet
        }

        guard self.provider != nil else {
            throw ConfigurationError.providerNotSet
        }

        return true
    }

    static let sharedInstance = InternalPaymentSDK()

    func configure(configuration: MobilabPaymentConfiguration) {
        self.configuration = configuration
        self.networkingClient = NetworkClientCore()
    }

    func addProvider(provider: PaymentServiceProvider) {
        self.provider = provider
    }

    func registrationManager() -> InternalRegistrationManager {
        do {
            if try self.isSDKConfigured() {
                return InternalRegistrationManager()
            }
        } catch let error as ConfigurationError {
            fatalError(error.description())
        } catch {
            fatalError()
        }

        // Code execution should never reach this line
        return InternalRegistrationManager()
    }
}
