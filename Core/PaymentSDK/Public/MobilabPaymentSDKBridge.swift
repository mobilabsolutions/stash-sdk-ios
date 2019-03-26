//
//  MobilabPaymentSDKBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentUI
import UIKit

@objc(MLMobilabPaymentSDK) public class MobilabPaymentSDKBridge: NSObject {
    @objc public static func configure(configuration: MobilabPaymentConfiguration) {
        MobilabPaymentSDK.configure(configuration: configuration)
    }

    @objc public static func getRegistrationManager() -> RegistrationManagerBridge {
        return RegistrationManagerBridge(manager: MobilabPaymentSDK.getRegistrationManager())
    }

    @objc public static func addProvider(provider: Any) {
        guard let provider = provider as? PaymentServiceProvider
        else { fatalError("Provided Payment Provider is not a payment provider.") }
        InternalPaymentSDK.sharedInstance.addProvider(provider: provider)
    }
}

@objc(MLRegistrationManager) public class RegistrationManagerBridge: NSObject {
    private let manager: RegistrationManager

    init(manager: RegistrationManager) {
        self.manager = manager
    }

    @objc(MLCreditCardData) public class CreditCardDataBridge: NSObject, CreditCardDataInitializible {
        let creditCardData: CreditCardData

        @objc public required init(cardNumber: String, cvv: String, expiryMonth: Int, expiryYear: Int, holderName: String?, billingData: BillingData) throws {
            self.creditCardData = try CreditCardData(cardNumber: cardNumber, cvv: cvv,
                                                     expiryMonth: expiryMonth, expiryYear: expiryYear,
                                                     holderName: holderName, billingData: billingData)
        }
    }

    @objc(MLSEPAData) public class SEPADataBridge: NSObject, SEPADataInitializible {
        let sepaData: SEPAData

        @objc public required init(iban: String, bic: String, billingData: BillingData) throws {
            self.sepaData = try SEPAData(iban: iban, bic: bic, billingData: billingData)
        }
    }

    @objc(MLPaymentMethodUIConfiguration) public class MLPaymentMethodUIConfiguration: NSObject {
        let configuration: PaymentMethodUIConfiguration

        /// Initialize the payment method UI configuration
        ///
        /// - Parameters:
        ///   - backgroundColor: The background color to use in the UI or `nil` for the default value
        ///   - textColor: The font color to use in the UI or `nil` for the default value
        ///   - buttonColor: The button color to use for enabled buttons in the UI or `nil` for the default value
        ///   - mediumEmphasisColor: The color to use for subtitles and other UI elements requiring medium emphasis
        ///                          or `nil` for the default value
        ///   - cellBackgroundColor: The background color to use for cells in the UI or `nil` for the default value
        ///   - buttonTextColor: The button text color to use in the UI or `nil` for the default value
        ///   - buttonDisabledColor: The button color to use when a button is disabled in the UI or `nil` for the default value
        @objc public required init(backgroundColor: UIColor?,
                                   textColor: UIColor?,
                                   buttonColor: UIColor?,
                                   mediumEmphasisColor: UIColor?,
                                   cellBackgroundColor: UIColor?,
                                   buttonTextColor: UIColor?,
                                   buttonDisabledColor: UIColor?) {
            self.configuration = PaymentMethodUIConfiguration(backgroundColor: backgroundColor,
                                                              textColor: textColor,
                                                              buttonColor: buttonColor,
                                                              mediumEmphasisColor: mediumEmphasisColor,
                                                              cellBackgroundColor: cellBackgroundColor,
                                                              buttonTextColor: buttonTextColor,
                                                              buttonDisabledColor: buttonDisabledColor)
        }
    }

    @objc public func registerCreditCard(creditCardData: CreditCardDataBridge, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerCreditCard(creditCardData: creditCardData.creditCardData,
                                        completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerSEPAAccount(sepaData: SEPADataBridge, completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerSEPAAccount(sepaData: sepaData.sepaData, completion: self.bridgedCompletion(completion: completion))
    }

    @objc public func registerPaymentMethodUsingUI(on viewController: UIViewController,
                                                   configuration: MLPaymentMethodUIConfiguration,
                                                   completion: @escaping (String?, MLError?) -> Void) {
        self.manager.registerPaymentMethodUsingUI(on: viewController, configuration: configuration.configuration, completion: self.bridgedCompletion(completion: completion))
    }

    private func bridgedCompletion(completion: @escaping (String?, MLError?) -> Void) -> RegistrationResultCompletion {
        let bridged: ((RegistrationResult) -> Void) = { result in
            switch result {
            case let .success(alias): completion(alias, nil)
            case let .failure(error): completion(nil, error)
            }
        }

        return bridged
    }
}
