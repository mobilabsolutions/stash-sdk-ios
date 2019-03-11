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
    var status: StatusType
    var pseudoCardPan: String?
    var cardType: String?
    var truncatedCardPan: String?
    var cardExpireDate: String?
    var errorCode: String?
    var errorMessage: String?
    var customerMessage: String?

    var error: MLError? {
        if self.status != .valid {
            return MLError(title: "PSP Error", description: self.errorMessage!, code: Int(self.errorCode!)!)
        }
        return nil
    }

    init(status: StatusType, pseudoCardPan: String, cardType: String, truncatedCardPan: String, cardExpireDate: String) {
        self.status = status
        self.pseudoCardPan = pseudoCardPan
        self.cardType = cardType
        self.truncatedCardPan = truncatedCardPan
        self.cardExpireDate = cardExpireDate
    }

    init(status: StatusType, errorCode: String, errorMessage: String, customerMessage: String) {
        self.status = status
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.customerMessage = customerMessage
    }
}

extension RegisterCreditCardResponse: Decodable {
    enum DecodableKeys: String, CodingKey {
        case status
        case pseudocardpan
        case cardtype
        case truncatedcardpan
        case cardexpiredate
        case errorcode
        case errormessage
        case customermessage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableKeys.self)
        let status: StatusType = try container.decode(StatusType.self, forKey: .status)
        if status == .valid {
            let pseudocardpan: String = try container.decode(String.self, forKey: .pseudocardpan)
            let cardtype: String = try container.decode(String.self, forKey: .cardtype)
            let truncatedcardpan: String = try container.decode(String.self, forKey: .truncatedcardpan)
            let cardexpiredate: String = try container.decode(String.self, forKey: .cardexpiredate)

            self.init(status: status, pseudoCardPan: pseudocardpan, cardType: cardtype, truncatedCardPan: truncatedcardpan, cardExpireDate: cardexpiredate)
        } else {
            let errorcode: String = try container.decode(String.self, forKey: .errorcode)
            let errormessage: String = try container.decode(String.self, forKey: .errormessage)
            let customermessage: String = try container.decode(String.self, forKey: .customermessage)

            self.init(status: status, errorCode: errorcode, errorMessage: errormessage, customerMessage: customermessage)
        }
    }
}
