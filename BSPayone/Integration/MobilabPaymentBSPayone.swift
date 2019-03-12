//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public class MobilabPaymentBSPayone: PaymentServiceProvider {
    public let pspIdentifier: String
    public let publicKey: String

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping RegistrationResultCompletion) {
        if let creditCardRequest = getCreditCardDate(from: registrationRequest) {
            self.handleCreditCardRequest(creditCardRequest: creditCardRequest, pspExtra: registrationRequest.pspData, completion: completion)
        } else if self.isSepaRequest(registrationRequest: registrationRequest) {
            completion(.success(nil))
        } else {
            completion(.failure(MLError(title: "PSP Error", description: "Unknown payment method parameters", code: 0)))
        }
    }

    public init(publicKey: String) {
        self.networkingClient = NetworkClientBSPayone()
        self.publicKey = publicKey
        self.pspIdentifier = "BS_PAYONE"
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardBSPayoneData, pspExtra: PSPExtra,
                                         completion: @escaping RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspExtra: pspExtra, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardDate(from registrationRequest: RegistrationRequest) -> CreditCardBSPayoneData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData
        else { return nil }

        let bsCreditCardRequest = CreditCardBSPayoneData(cardPan: cardData.cardNumber,
                                                         cardType: cardData.cardType,
                                                         cardExpireDate: String(format: "%02d%02d", cardData.expiryYear, cardData.expiryMonth),
                                                         cardCVC2: cardData.cvv)

        return bsCreditCardRequest
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }
}
