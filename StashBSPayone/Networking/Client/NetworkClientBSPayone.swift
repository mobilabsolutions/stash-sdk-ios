//
//  NetworkClientBSPayone.swift
//  StashBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

class NetworkClientBSPayone: NetworkClient {
    func registerCreditCard(creditCardData: CreditCardBSPayoneData, pspData: BSPayoneData, completion: @escaping Completion<String>) {
        let router = RouterRequestBSPayone(service: .registerCreditCard(creditCardData, pspData))
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
