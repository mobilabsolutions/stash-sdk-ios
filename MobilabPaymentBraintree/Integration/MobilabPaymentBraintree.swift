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

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey: String?,
                                          uniqueRegistrationIdentifier _: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: BraintreeData.self)
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

        } catch let error as MobilabPaymentError {
            completion(.failure(error))
        } catch {
            completion(.failure(MobilabPaymentError.other(GenericErrorDetails.from(error: error))))
        }
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.payPal]
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.payPal]
    }

    public func viewController(for _: PaymentMethodType, billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        let viewController = PayPalLoadingViewController(uiConfiguration: configuration)
        viewController.billingData = billingData
        return viewController
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

    private func conditionallyPrintIdempotencyWarning(idempotencyKey: String?) {
        guard let key = idempotencyKey
        else { return }

        print("WARNING: Braintree does not support idempotency for registrations. Providing key \(key) will not have any effect.")
    }
}
