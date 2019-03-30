//
//  NetworkClientBSPayone.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

class NetworkClientAdyen: NetworkClient {
    func registerCreditCard(creditCardData: CreditCardAdyenData, pspData: AdyenData, completion: @escaping Completion<String>) {
        let router = RouterRequestAdyen(service: .registerCreditCard(creditCardData), pspData: pspData)
        fetch(with: router, responseType: RegisterCreditCardResponse.self, errorType: RegisterCreditCardResponseError.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.pseudoCardPan))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func registerSEPA(sepaData: SEPAAdyenData, pspData: AdyenData, completion: @escaping Completion<String>) {
        let router = RouterRequestAdyen(service: .registerSEPA(sepaData), pspData: pspData)
        fetch(with: router, responseType: RegisterCreditCardResponse.self, errorType: RegisterCreditCardResponseError.self) { result in
            switch result {
            case let .success(response):
                completion(.success(response.pseudoCardPan))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
