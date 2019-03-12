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
    public let pspType: String
    public let publicKey: String

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping (NetworkClientResult<String, MLError>) -> Void) {
        let registerCreditCardRequest = CreditCardBSPayoneData.from(registrationData: registrationRequest.registrationData)
        let pspExtra = PSPExtra.from(data: registrationRequest.pspData)

        guard registerCreditCardRequest.isValid(), let _pspExtra = pspExtra else {
            completion(.failure(MLError(title: "PSP Error", description: "Invalid Credit Card Registration parameters", code: 0)))
            return
        }

        self.networkingClient?.registerCreditCard(creditCardData: registerCreditCardRequest, pspExtra: _pspExtra, completion: completion)
    }

    public init(publicKey: String) {
        self.networkingClient = NetworkClientBSPayone()
        self.publicKey = publicKey
        self.pspType = "BS_PAYONE"
    }
}
