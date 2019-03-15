//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public class MobilabPaymentBraintree: PaymentServiceProvider {
    public let pspIdentifier: String
    public let publicKey: String

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping RegistrationResultCompletion) {
        guard self.isPayPalRequest(registrationRequest: registrationRequest) else {
            completion(.failure(MLError(description: BraintreeIntegrationError.unsupportedPaymentMethod.description(), code: 1)))
            return
        }

        self.handlePayPalRequest(pspExtra: registrationRequest.pspData, completion: completion)
    }

    public init(publicKey: String) {
        self.publicKey = publicKey
        self.pspIdentifier = "BS_PAYONE"
    }

    private func handlePayPalRequest(pspExtra _: PSPExtra,
                                     completion _: @escaping RegistrationResultCompletion) {
//        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspExtra: pspExtra, completion: { result in
//            switch result {
//            case let .success(value): completion(.success(.some(value)))
//            case let .failure(error): completion(.failure(error))
//            }
//        })
    }

//    private func getCreditCardDate(from registrationRequest: RegistrationRequest) throws -> CreditCardBSPayoneData? {
//        guard let cardData = registrationRequest.registrationData as? CreditCardData
//        else { return nil }
//
//        guard let cardType = cardData.cardType.bsCardTypeIdentifier
//        else { throw BSIntegrationError.unsupportedCreditCardType }
//
//        let bsCreditCardRequest = CreditCardBSPayoneData(cardPan: cardData.cardNumber,
//                                                         cardType: cardType,
//                                                         cardExpireDate: String(format: "%02d%02d", cardData.expiryYear, cardData.expiryMonth),
//                                                         cardCVC2: cardData.cvv)
//
//        return bsCreditCardRequest
//    }
//
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
