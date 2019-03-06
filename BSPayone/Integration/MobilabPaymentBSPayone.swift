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
    var networkingClient: NetworkClientBSPayone?
    public var pspType: String
    public var publicKey: String

    public func handleRegistrationRequest(registrationRequest _: RegistrationRequest, completion: @escaping (NetworkClientResult<String, MLError>) -> Void) {
        self.networkingClient?.registerCreditCard(paymentMethod: "", completion: { _ in

        })

        completion(.success("TestALias"))
    }

    public init(publicKey: String) {
        self.networkingClient = NetworkClientBSPayone()
        self.publicKey = publicKey
        self.pspType = "BS_PAYONE"
    }
}
