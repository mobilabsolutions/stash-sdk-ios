//
//  StashAdyen.swift
//  Adyen
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Adyen
#if CARTHAGE
    import AdyenCard
#endif
import StashCore
import UIKit

/// The Adyen PSP module. See [here](https://github.com/mobilabsolutions/payment-sdk-ios-open/wiki/Adyen)
/// for more information on things to keep in mind when using that PSP.
public class StashAdyen: PaymentServiceProvider {
    /// See documentation for the `PaymentServiceProvider` protocol in the Core module.
    public let pspIdentifier: StashPaymentProvider

    /// See documentation for the `PaymentServiceProvider` protocol in the Core module.
    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey: String?,
                                          uniqueRegistrationIdentifier: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        Log.event(description: "function initiated")

        guard let pspData = AdyenData(pspData: registrationRequest.pspData) else {
            return completion(.failure(StashError.configuration(.pspInvalidConfiguration)))
        }
        do {
            if let creditCardData = try getCreditCardData(from: registrationRequest) {
                self.conditionallyPrintIdempotencyWarning(idempotencyKey: idempotencyKey)
                self.handleCreditCardRequest(creditCardData: creditCardData,
                                             pspData: pspData,
                                             uniqueRegistrationIdentifier: uniqueRegistrationIdentifier,
                                             completion: completion)
            } else if let sepaData = try getSEPAData(from: registrationRequest) {
                self.handleSEPARequest(sepaData: sepaData,
                                       completion: completion)
            } else {
                completion(.failure(StashError.configuration(.pspInvalidConfiguration)))
            }
        } catch let error as StashError {
            completion(.failure(error))
        } catch {
            completion(.failure(StashError.other(GenericErrorDetails.from(error: error))))
        }
    }

    public func handle3DS(request: ThreeDSRequest, viewController: UIViewController, completion: @escaping ThreeDSAuthenticationCompletion) {
        let handler = Adyen3DSHandler.sharedInstance
        handler.handle(with: request, viewController: viewController) { result in
            completion(result)
        }
    }

    /// See documentation for the `PaymentServiceProvider` protocol in the Core module. Adyen supports SEPA and Credit Card payment methods.
    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    /// See documentation for the `PaymentServiceProvider` protocol in the Core module. Adyen supports SEPA and Credit Card payment methods for registration using UI.
    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    /// See documentation for the `PaymentServiceProvider` protocol in the Core module.
    public func viewController(for methodType: PaymentMethodType,
                               billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        Log.event(description: "function initiated")
        let viewController: (UIViewController & PaymentMethodDataProvider)?

        switch methodType {
        case .creditCard:
            viewController = CustomBackButtonContainerViewController(viewController: AdyenCreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                                     configuration: configuration)
        case .sepa:
            viewController = CustomBackButtonContainerViewController(viewController: AdyenSEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                                     configuration: configuration)
        case .payPal:
            viewController = nil
        }

        viewController?.title = "PAYMENT METHOD"

        return viewController
    }

    /// Create an instance that provides all of the SDK-required functionality for communication with the Adyen payment service provider.
    /// This instance can be used to initialize the SDK.
    public init() {
        self.pspIdentifier = .adyen
    }

    private func handleCreditCardRequest(creditCardData: CreditCardData,
                                         pspData: AdyenData,
                                         uniqueRegistrationIdentifier _: String,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        let creditCardPreparator = AdyenCreditCardExtraPreparator(creditCardData: creditCardData, cardEncryptionKey: pspData.clientEncryptionKey)
        do {
            let extra = try creditCardPreparator.prepare()
            let registration = PSPRegistration(pspAlias: nil, aliasExtra: AliasExtra(ccConfig: extra, billingData: creditCardData.billingData))
            completion(.success(registration))
        } catch let error as StashError {
            completion(.failure(error))
        } catch {
            completion(.failure(StashError.other(GenericErrorDetails.from(error: error))))
        }
    }

    private func handleSEPARequest(sepaData: SEPAAdyenData,
                                   completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        let billingData = sepaData.billingData ?? BillingData()
        let registration = PSPRegistration(pspAlias: nil, aliasExtra: AliasExtra(sepaConfig: sepaData.sepaExtra, billingData: billingData))
        completion(.success(registration))
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData else { return nil }
        return cardData
    }

    private func getSEPAData(from registrationRequest: RegistrationRequest) throws -> SEPAAdyenData? {
        guard let data = registrationRequest.registrationData as? SEPAData
        else { return nil }

        guard let ownerName = data.billingData.name?.fullName
        else { throw StashError.validation(.billingMissingName).loggedError() }

        return SEPAAdyenData(ownerName: ownerName, ibanNumber: data.iban, billingData: data.billingData, sepaExtra: data.toSEPAExtra())
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }

    private func conditionallyPrintIdempotencyWarning(idempotencyKey: String?) {
        guard let key = idempotencyKey
        else { return }

        print("WARNING: Adyen does not support idempotency for credit card registrations. Providing key \(key) will not have any effect.")
    }
}
