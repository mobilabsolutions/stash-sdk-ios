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
    case VALID
    case INVALID
    case ERROR
}

struct RegisterCreditCardResponse {
    var status: StatusType
    var pseudocardpan: String?
    var cardtype:String?
    var truncatedcardpan: String?
    var cardexpiredate:String?
    var errorcode:String?
    var errormessage: String?
    var customermessage:String?
    
    var error:MLError? {
        if status != .VALID {
            return MLError(title: "PSP Error", description: errormessage!, code: Int(errorcode!)!)
        }
        return nil
    }
    
    init(status: StatusType, pseudocardpan: String, cardtype: String, truncatedcardpan: String, cardexpiredate: String) {
        self.status = status
        self.pseudocardpan = pseudocardpan
        self.cardtype = cardtype
        self.truncatedcardpan = truncatedcardpan
        self.cardexpiredate = cardexpiredate
    }
    
    init(status: StatusType, errorcode: String, errormessage: String, customermessage: String) {
        self.status = status
        self.errorcode = errorcode
        self.errormessage = errormessage
        self.customermessage = customermessage
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
        if status == .VALID {
            let pseudocardpan: String = try container.decode(String.self, forKey: .pseudocardpan)
            let cardtype: String = try container.decode(String.self, forKey: .cardtype)
            let truncatedcardpan: String = try container.decode(String.self, forKey: .truncatedcardpan)
            let cardexpiredate: String = try container.decode(String.self, forKey: .cardexpiredate)
            
            self.init(status: status, pseudocardpan: pseudocardpan, cardtype: cardtype, truncatedcardpan: truncatedcardpan, cardexpiredate: cardexpiredate)
        } else {
            let errorcode: String = try container.decode(String.self, forKey: .errorcode)
            let errormessage: String = try container.decode(String.self, forKey: .errormessage)
            let customermessage: String = try container.decode(String.self, forKey: .customermessage)
            
            self.init(status: status, errorcode: errorcode, errormessage: errormessage, customermessage: customermessage)
        }
    }
}
