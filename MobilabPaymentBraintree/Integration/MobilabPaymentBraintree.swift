//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import BraintreeCard
import BraintreeCore
import BraintreeDataCollector
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
        Log.event(message: "initiated")
        guard let pspData = BraintreeData(pspData: registrationRequest.pspData) else {
            return completion(.failure(MobilabPaymentError.configuration(.pspInvalidConfiguration)))
        }

        let billingData = self.getBillingData(from: registrationRequest) ?? BillingData()

        do {
            if let creditCardRequest = try getCreditCardData(from: registrationRequest),
                let creditCardData = registrationRequest.registrationData as? CreditCardData,
                let creditCardExtra = creditCardData.toCreditCardExtra() {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest,
                                             pspData: pspData,
                                             creditCardExtra: creditCardExtra,
                                             billingData: billingData,
                                             idempotencyKey: idempotencyKey,
                                             completion: completion)
            } else if let _ = getPayPalData(from: registrationRequest) {
                self.handlePayPalRequest(viewController: registrationRequest.viewController,
                                         payPalData: pspData,
                                         idempotencyKey: idempotencyKey,
                                         completion: completion)
            } else {
                fatalError("MobiLab Payment SDK: Type of registration data provided can not be handled by SDK. Registration data type must be one of SEPAData, CreditCardData or PayPalData")
            }
        } catch let error as MobilabPaymentError {
            completion(.failure(error))
        } catch {
            completion(.failure(MobilabPaymentError.other(GenericErrorDetails.from(error: error))))
        }
    }

    /// See documentation for `PaymentServiceProvider` in the Core module. Braintree only supports PayPal payment methods.
    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.payPal, .creditCard]
    }

    /// See documentation for `PaymentServiceProvider` in the Core module. Braintree only supports PayPal payment methods for registration using the UI.
    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.payPal, .creditCard]
    }

    /// See documentation for `PaymentServiceProvider` in the Core module.
    public func viewController(for methodType: PaymentMethodType, billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        Log.event(message: "initiated")
        switch methodType {
        case .creditCard:
            return CustomBackButtonContainerViewController(viewController: BraintreeCreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .sepa:
            return nil
        case .payPal:
            let viewController = PayPalLoadingViewController(uiConfiguration: configuration)
            viewController.billingData = billingData
            return viewController
        }
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

    private func handleCreditCardRequest(creditCardRequest: CreditCardBraintreeData,
                                         pspData: BraintreeData,
                                         creditCardExtra: CreditCardExtra,
                                         billingData: BillingData,
                                         idempotencyKey: String?,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.conditionallyPrintIdempotencyWarning(idempotencyKey: idempotencyKey)
        guard let braintreeClient = BTAPIClient(authorization: pspData.clientToken) else {
            fatalError("Braintree client can't be authorized with applied client token")
        }
        let dataCollector = BTDataCollector(apiClient: braintreeClient)
        let cardClient = BTCardClient(apiClient: braintreeClient)
        let card = BTCard(number: creditCardRequest.cardPan,
                          expirationMonth: creditCardRequest.expirationMonth,
                          expirationYear: creditCardRequest.expirationYear,
                          cvv: creditCardRequest.cardCVC2)
        cardClient.tokenizeCard(card) { tokenizedCard, error in
            if let tokenizedCard = tokenizedCard {
                dataCollector.collectCardFraudData { deviceData in
                    let updatedCreditCardExtra = CreditCardExtra(ccExpiry: creditCardExtra.ccExpiry,
                                                                 ccMask: creditCardExtra.ccMask,
                                                                 ccType: creditCardExtra.ccType,
                                                                 ccHolderName: creditCardExtra.ccHolderName,
                                                                 nonce: tokenizedCard.nonce,
                                                                 deviceData: deviceData)
                    let aliasExtra = AliasExtra(ccConfig: updatedCreditCardExtra, billingData: billingData)
                    let registration = PSPRegistration(pspAlias: nil, aliasExtra: aliasExtra, overwritingExtraAliasInfo: nil)
                    completion(.success(registration))
                }
            } else if let error = error {
                let mlError = error as? MobilabPaymentError ?? MobilabPaymentError.other(GenericErrorDetails.from(error: error))
                completion(.failure(mlError))
            }
        }
    }

    private func handlePayPalRequest(viewController: UIViewController?,
                                     payPalData: BraintreeData,
                                     idempotencyKey: String?,
                                     completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.conditionallyPrintIdempotencyWarning(idempotencyKey: idempotencyKey)
        guard let presentingViewController = viewController else {
            fatalError("MobiLab Payment SDK: Braintree module is missing presenting view controller")
        }
        let payPalManager = PayPalUIManager(viewController: presentingViewController,
                                            clientToken: payPalData.clientToken)
        payPalManager.didCreatePaymentMethodCompletion = { method in
            if let payPalData = method as? PayPalData {
                let aliasExtra = AliasExtra(payPalConfig: PayPalExtra(nonce: payPalData.nonce, deviceData: payPalData.deviceData), billingData: BillingData(email: payPalData.email))
                let registration = PSPRegistration(pspAlias: nil, aliasExtra: aliasExtra, overwritingExtraAliasInfo: payPalData.extraAliasInfo)
                completion(.success(registration))
            } else {
                completion(.failure(MobilabPaymentError.configuration(.pspInvalidConfiguration)))
            }
        }
        payPalManager.errorWhileUsingPayPal = { error in
            completion(.failure(error))
        }
        payPalManager.showPayPalUI()
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardBraintreeData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData else { return nil }
        guard let clientToken = registrationRequest.pspData.clientToken else { return nil }
        return CreditCardBraintreeData(clientToken: clientToken,
                                       cardPan: cardData.cardNumber,
                                       expirationMonth: String(cardData.expiryMonth),
                                       expirationYear: String(cardData.expiryYear),
                                       cardCVC2: cardData.cvv)
    }

    private func getPayPalData(from registrationRequest: RegistrationRequest) -> BraintreeData? {
        guard let _ = registrationRequest.registrationData as? PayPalPlaceholderData else { return nil }
        return BraintreeData(pspData: registrationRequest.pspData)
    }

    private func getBillingData(from registrationRequest: RegistrationRequest) -> BillingData? {
        if let data = registrationRequest.registrationData as? CreditCardData {
            return BillingData(country: data.country, basedOn: data.billingData)
        }
        return nil
    }

    private func conditionallyPrintIdempotencyWarning(idempotencyKey: String?) {
        guard let key = idempotencyKey
        else { return }

        print("WARNING: Braintree does not support idempotency for registrations. Providing key \(key) will not have any effect.")
    }
}
