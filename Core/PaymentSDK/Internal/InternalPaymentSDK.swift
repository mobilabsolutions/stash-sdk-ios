//
//  MLInternalPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class InternalPaymentSDK {
    var networkingClient: NetworkClientCore?
    var provider: PaymentServiceProvider?

    static let sharedInstance = InternalPaymentSDK()

    func setUp(provider: PaymentServiceProvider) {
        self.provider = provider

        MobilabPaymentConfigurationBuilder.sharedInstance.setupConfiguration(token: provider.publicKey, pspType: provider.pspType)
        self.networkingClient = NetworkClientCore()
    }

    func registrationManager() -> InternalRegistrationManager {
        guard let networkingClient = self.networkingClient, let provider = self.provider
        else { fatalError("MobiLab SDK not setup") }

        return InternalRegistrationManager(provider: provider, client: networkingClient)
    }
}
