//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import BraintreeCore
import MobilabPaymentCore
import UIKit

public class MobilabPaymentBraintree: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider
    public let publicKey: String

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        guard self.isPayPalRequest(registrationRequest: registrationRequest) else {
            completion(.failure(MLError(description: BraintreeIntegrationError.unsupportedPaymentMethod.description(), code: 1)))
            return
        }

        completion(.success(nil))
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.payPal]
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.payPal]
    }

    public func viewController(for _: PaymentMethodType) -> (UIViewController & PaymentMethodDataProvider)? {
        return PayPalViewController()
    }

    public init(tokenizationKey: String, urlScheme: String) {
        self.publicKey = tokenizationKey
        self.pspIdentifier = .braintree

        BTAppSwitch.setReturnURLScheme(urlScheme)
    }

    public static func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare(BTAppSwitch.sharedInstance().returnURLScheme) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }

    private func isPayPalRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is PayPalData
    }

    private enum BraintreeIntegrationError: Error {
        case unsupportedPaymentMethod

        func description() -> String {
            switch self {
            case .unsupportedPaymentMethod:
                return "Unsupported Payment Method"
            }
        }
    }
}
