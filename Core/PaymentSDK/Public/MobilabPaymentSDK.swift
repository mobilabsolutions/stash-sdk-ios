//
//  MLPaymentSDK.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public typealias RegistrationResult = NetworkClientResult<String, MLError>
public typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

public class MobilabPaymentSDK {
    public static func configure(configuration: MobilabPaymentConfiguration) {
        InternalPaymentSDK.sharedInstance.configure(configuration: configuration)
    }

    public static func addProvider(provider: PaymentServiceProvider) {
        InternalPaymentSDK.sharedInstance.addProvider(provider: provider)
    }

    public static func getRegisterManager() -> RegistrationManager {
        return RegistrationManager()
    }
}
