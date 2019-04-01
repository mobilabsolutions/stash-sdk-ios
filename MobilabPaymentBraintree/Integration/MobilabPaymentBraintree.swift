//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import BraintreeCore
import MobilabPaymentCore
import MobilabPaymentUI
import UIKit

public class MobilabPaymentBraintree: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: BraintreeData.self)

            let paypalViewController = PayPalViewController(clientToken: pspData.clientToken)
            paypalViewController.didCreatePaymentMethodCompletion = { method in
                if let payPalData = method as? PayPalData {
                    completion(.success(payPalData.nonce))
                } else {
                    fatalError("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData, CreditCardData or PayPalData")
                }
            }
            guard let presentingViewController = registrationRequest.viewController else {
                fatalError("MobiLab Payment SDK: Braintree module is missing presenting view controller")
            }
            presentingViewController.present(paypalViewController, animated: true, completion: nil)

        } catch PaymentServiceProviderError.missingOrInvalidConfigurationData {
            completion(.failure(MLError(title: "Missing configuration data", description: "Provided configuration data is wrong", code: 1)))
        } catch {
            completion(.failure(MLError(title: "Unknown error occurred", description: "An unknown error occurred while handling payment method registration in Braintree module", code: 3)))
        }
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.payPal]
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.payPal]
    }

    public func viewController(for _: PaymentMethodType, billingData _: BillingData?, configuration _: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        return LoadingViewController()
    }

    public init(urlScheme: String) {
        self.pspIdentifier = .braintree

        BTAppSwitch.setReturnURLScheme(urlScheme)
    }

    public static func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare(BTAppSwitch.sharedInstance().returnURLScheme) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }

    private enum BraintreeIntegrationError: Error {
        case invalidClientToken

        func description() -> String {
            switch self {
            case .invalidClientToken:
                return "Invalid client token"
            }
        }
    }
}
