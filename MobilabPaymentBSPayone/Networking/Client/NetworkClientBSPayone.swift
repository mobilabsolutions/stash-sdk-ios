//
//  NetworkClientBSPayone.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

class NetworkClientBSPayone: NetworkClient {
    func registerCreditCard(creditCardData: CreditCardBSPayoneData, pspExtra: PSPExtra, completion: @escaping Completion<String>) {
        let router = RouterRequestBSPayone(service: .registerCreditCard(creditCardData, pspExtra))
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
