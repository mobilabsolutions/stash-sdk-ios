//
//  MLCreditCardData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public class CreditCardData: BaseMethodData, Encodable {
    var holderName: String
    var cardNumber: String
    var cardType: String = "V"
    var CVV: String
    var expiryMonth: Int
    var expiryYear: Int

    public init(holderName: String, cardNumber: String, CVV: String, expiryMonth: Int, expiryYear: Int) {
        self.holderName = holderName
        self.cardNumber = cardNumber
        self.CVV = CVV
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
    
    enum EncodingKeys:String,CodingKey {
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
    
    func toBSPayoneData() -> Data? {
        return self.toData()
    }
    
}
