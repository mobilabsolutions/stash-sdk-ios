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
    public let publicKey: String

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            if let creditCardRequest = try getCreditCardDate(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest, pspExtra: registrationRequest.pspData, completion: completion)
            } else if self.isSepaRequest(registrationRequest: registrationRequest) {
                completion(.success(nil))
            } else {
                #warning("Update codes here when errors are finalized")
                completion(.failure(MLError(title: "PSP Error", description: "Unknown payment method parameters", code: 0)))
            }
        } catch BSIntegrationError.unsupportedCreditCardType {
            completion(.failure(MLError(title: "Unsupported Credit Card Type", description: "The provided credit card type is not supported", code: 1)))
        } catch {
            completion(.failure(MLError(title: "Unknown error occurred", description: "An unknown error occurred while handling payment method registration in BS module", code: 3)))
        }
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    public init(publicKey: String) {
        self.networkingClient = NetworkClientBSPayone()
        self.publicKey = publicKey
        self.pspIdentifier = .bsPayone
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardBSPayoneData, pspExtra: PSPExtra,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspExtra: pspExtra, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardDate(from registrationRequest: RegistrationRequest) throws -> CreditCardBSPayoneData? {
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

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }

    private enum BSIntegrationError: Error {
        case unsupportedCreditCardType
    }
}
