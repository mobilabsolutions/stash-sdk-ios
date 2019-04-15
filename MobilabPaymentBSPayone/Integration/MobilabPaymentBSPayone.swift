//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

public class MobilabPaymentBSPayone: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey _: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: BSPayoneData.self)

            if let creditCardRequest = try getCreditCardData(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest, pspData: pspData, completion: completion)
            } else if let _ = try getSepaData(from: registrationRequest) {
                completion(.success(nil))
            } else {
                #warning("Update codes here when errors are finalized")
                completion(.failure(MLError(title: "PSP Error", description: "Unknown payment method parameters", code: 0)))
            }
        } catch PaymentServiceProviderError.missingOrInvalidConfigurationData {
            completion(.failure(MLError(title: "Missing configuration data", description: "Provided configuration data is wrong", code: 1)))
        } catch BSIntegrationError.unsupportedCreditCardType {
            completion(.failure(MLError(title: "Unsupported Credit Card Type", description: "The provided credit card type is not supported", code: 1)))
        } catch BSIntegrationError.missingBIC {
            completion(.failure(MLError(title: "BIC missing", description: "For SEPA payments with BS Payone, BIC is required", code: 1)))
        } catch {
            completion(.failure(MLError(title: "Unknown error occurred", description: "An unknown error occurred while handling payment method registration in BS module", code: 3)))
        }
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.creditCard, .sepa]
    }

    public func viewController(for methodType: PaymentMethodType,
                               billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        switch methodType {
        case .creditCard:
            return CustomBackButtonContainerViewController(viewController: BSCreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .sepa:
            return CustomBackButtonContainerViewController(viewController: BSSEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .payPal:
            return nil
        }
    }

    public init() {
        self.networkingClient = NetworkClientBSPayone()
        self.pspIdentifier = .bsPayone
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardBSPayoneData, pspData: BSPayoneData,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardBSPayoneData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData
        else { return nil }

        guard let cardType = cardData.cardType.bsCardTypeIdentifier
        else { throw BSIntegrationError.unsupportedCreditCardType }

        let bsCreditCardRequest = CreditCardBSPayoneData(cardPan: cardData.cardNumber,
                                                         cardType: cardType,
                                                         cardExpireDate: String(format: "%02d%02d", cardData.expiryYear, cardData.expiryMonth),
                                                         cardCVC2: cardData.cvv)

        return bsCreditCardRequest
    }

    private func getSepaData(from registrationRequest: RegistrationRequest) throws -> SEPABSPayoneData? {
        guard let data = registrationRequest.registrationData as? SEPAData
        else { return nil }

        guard let bic = data.bic
        else { throw BSIntegrationError.missingBIC }

        return SEPABSPayoneData(iban: data.iban, bic: bic)
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }

    private enum BSIntegrationError: Error {
        case unsupportedCreditCardType
        case missingBIC
    }
}
