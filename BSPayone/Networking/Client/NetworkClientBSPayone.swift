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
    func registerCreditCard(paymentMethod _: String, completion _: @escaping Completion<String>) {
        let requestObject = RegisterCreditCardRequest(creditCardNumber: "")
        let router = RouterRequestBSPayone(service: .registerCreditCard(requestObject))

        fetch(with: router, responseType: RegisterCreditCardResponse.self) { _ in
        }
    }
}
