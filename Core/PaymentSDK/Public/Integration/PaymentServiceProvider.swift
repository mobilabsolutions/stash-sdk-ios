//
//  PSPIntegrationProtocol.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//
import UIKit

public enum MobilabPaymentProvider: String {
    case bsPayone = "BS_PAYONE"
    case braintree = "BRAINTREE"
}

public protocol PaymentServiceProvider {
    typealias RegistrationResult = NetworkClientResult<String?, MLError>
    typealias RegistrationResultCompletion = ((RegistrationResult) -> Void)

    var pspIdentifier: MobilabPaymentProvider { get }
    var publicKey: String { get }

    func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping RegistrationResultCompletion)

    var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] { get }
    func viewController(for paymentMethodType: PaymentMethodType) -> (UIViewController & PaymentMethodDataProvider)?
}

public extension PaymentServiceProvider {
    var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return []
    }

    func viewController(for _: PaymentMethodType) -> (UIViewController & PaymentMethodDataProvider)? {
        return nil
    }
}
