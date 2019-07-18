//
//  PaymentProviderIntegrationBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLPaymentProviderIntegration) public class PaymentProviderIntegrationBridge: NSObject {
    let integration: PaymentProviderIntegration
    
    @objc public init?(paymentServiceProvider bridge: PaymentProviderBridge, paymentMethodTypes: Set<Int>) {
        let paymentMethods = paymentMethodTypes.map({ (method) -> PaymentMethodType in
            guard let bridgeType = PaymentMethodTypeBridge(rawValue: method),
                let type = bridgeType.paymentMethodType
                else { fatalError("Provided value (\(method)) does not correspond to a payment method") }
            return type
        })
        
        guard let integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider,
                                                           paymentMethodTypes: Set(paymentMethods))
            else { return nil }
        
        self.integration = integration
    }
    
    @objc public init(paymentServiceProvider bridge: PaymentProviderBridge) {
        self.integration = PaymentProviderIntegration(paymentServiceProvider: bridge.paymentProvider)
    }
}
