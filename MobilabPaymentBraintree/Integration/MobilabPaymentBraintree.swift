//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import BraintreeCore
import MobilabPaymentCore
import UIKit

/// The Braintree PSP module. See [here](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki/Braintree)
/// for more information on things to keep in mind when using that PSP.
public class MobilabPaymentBraintree: PaymentServiceProvider {
    /// See documentation for `PaymentServiceProvider` in the Core module
    public let pspIdentifier: MobilabPaymentProvider

    /// See documentation for `PaymentServiceProvider` in the Core module
    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey: String?,
                                          uniqueRegistrationIdentifier _: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        guard let pspData = BraintreeData(pspData: registrationRequest.pspData) else {
            return completion(.failure(MobilabPaymentError.configuration(.pspInvalidConfiguration)))
        }
        guard let presentingViewController = registrationRequest.viewController else {
            fatalError("MobiLab Payment SDK: Braintree module is missing presenting view controller")
        }
        self.conditionallyPrintIdempotencyWarning(idempotencyKey: idempotencyKey)

        let payPalManager = PayPalUIManager(viewController: presentingViewController, clientToken: pspData.clientToken)
        payPalManager.didCreatePaymentMethodCompletion = { method in
            if let payPalData = method as? PayPalData {
                let aliasExtra = AliasExtra(payPalConfig: PayPalExtra(nonce: payPalData.nonce, deviceData: payPalData.deviceData), billingData: BillingData(email: payPalData.email))
                let registration = PSPRegistration(pspAlias: nil, aliasExtra: aliasExtra, overwritingExtraAliasInfo: payPalData.extraAliasInfo)
                completion(.success(registration))
            } else {
                fatalError("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData, CreditCardData or PayPalData")
            }
        }
        payPalManager.errorWhileUsingPayPal = { error in
            completion(.failure(error))
        }
        payPalManager.showPayPalUI()
    }

    /// See documentation for `PaymentServiceProvider` in the Core module. Braintree only supports PayPal payment methods.
    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.payPal]
    }

    /// See documentation for `PaymentServiceProvider` in the Core module. Braintree only supports PayPal payment methods for registration using the UI.
    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.payPal]
    }

    /// See documentation for `PaymentServiceProvider` in the Core module.
    public func viewController(for _: PaymentMethodType, billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        let viewController = PayPalLoadingViewController(uiConfiguration: configuration)
        viewController.billingData = billingData
        return viewController
    }

    /// Create a new instance of the Braintree module. This instance can be used to initialize the SDK.
    ///
    /// - Parameter urlScheme: The registered URL scheme.
    /// See [here](https://github.com/mobilabsolutions/payment-sdk-ios-open#paypal-account-registration) for more considerations.
    public init(urlScheme: String) {
        self.pspIdentifier = .braintree

        BTAppSwitch.setReturnURLScheme(urlScheme)
    }

    /// Handle a potential Braintree URL redirection that comes in via the UIApplicationDelegate's `application(_:open:options:)`
    ///
    /// - Parameters:
    ///   - url: The url as provided by the UIApplicationDelegate method
    ///   - options: The options as provided by the UIApplicationDelegate method
    /// - Returns: A boolean indicating whether or not the Braintree module handled the request.
    public static func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare(BTAppSwitch.sharedInstance().returnURLScheme) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }

    private func conditionallyPrintIdempotencyWarning(idempotencyKey: String?) {
        guard let key = idempotencyKey
        else { return }

        print("WARNING: Braintree does not support idempotency for registrations. Providing key \(key) will not have any effect.")
    }
}
