//
//  RegisterCreditCardResponse.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

enum StatusType: String, Codable {
    case valid = "VALID"
    case invalid = "INVALID"
    case error = "ERROR"
}

struct RegisterCreditCardResponse {
    let status: StatusType
    let pseudoCardPan: String
    let cardType: String
    let truncatedCardPan: String
    let cardExpireDate: String

    init(status: StatusType, pseudoCardPan: String, cardType: String, truncatedCardPan: String, cardExpireDate: String) {
        self.status = status
        self.pseudoCardPan = pseudoCardPan
        self.cardType = cardType
        self.truncatedCardPan = truncatedCardPan
        self.cardExpireDate = cardExpireDate
    }
}

extension RegisterCreditCardResponse: Decodable {
    enum DecodableKeys: String, CodingKey {
        case status
        case pseudocardpan
        case cardtype
        case truncatedcardpan
        case cardexpiredate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableKeys.self)
        let status: StatusType = try container.decode(StatusType.self, forKey: .status)
        guard status == .valid
        else { throw NetworkClientError.shouldTryDecodingErrorResponse }

        let pseudocardpan: String = try container.decode(String.self, forKey: .pseudocardpan)
        let cardtype: String = try container.decode(String.self, forKey: .cardtype)
        let truncatedcardpan: String = try container.decode(String.self, forKey: .truncatedcardpan)
        let cardexpiredate: String = try container.decode(String.self, forKey: .cardexpiredate)

        self.init(status: status, pseudoCardPan: pseudocardpan, cardType: cardtype, truncatedCardPan: truncatedcardpan, cardExpireDate: cardexpiredate)
    }
}
