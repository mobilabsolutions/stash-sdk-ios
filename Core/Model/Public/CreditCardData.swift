//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct CreditCardData {
    let holderName: String
    let cardNumber: String
    let cardType: String = "V"
    let CVV: String
    let expiryMonth: Int
    let expiryYear: Int
}

extension CreditCardData: BaseMethodData {
    func toBSPayoneData() -> Data? {
        return self.toData()
    }
}

extension CreditCardData: Codable {
    enum EncodingKeys: String, CodingKey {
        case cardNumber = "cardPan"
        case CVV = "cardCVC2"
        case cardExpireDate
        case cardType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(cardNumber, forKey: .cardNumber)
        try container.encode(CVV, forKey: .CVV)
        try container.encode(cardType, forKey: .cardType)
        try container.encode("\(expiryYear)\(String(format: "%02d", expiryMonth))", forKey: .cardExpireDate)
    }
}
