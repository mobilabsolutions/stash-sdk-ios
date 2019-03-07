//
//  RegisterCreditCardRequest.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public struct CreditCardBSPayoneData: Codable {
    
    var aId: String = "42949"
    var cardPan: String?
    var cardType: String?
    var cardExpireDate: String?
    var cardCVC2:String?

    private enum CodingKeys: String, CodingKey {
        case cardPan
        case cardType
        case cardExpireDate
        case cardCVC2
    }
    
    public static func from(registrationData: Data?) -> CreditCardBSPayoneData {
        
        if let data = registrationData, let decoded = try? JSONDecoder().decode(CreditCardBSPayoneData.self, from: data) {
            return decoded
        }
        return CreditCardBSPayoneData()
    }
    
    func isValid() -> Bool {
        if let _ = cardPan, let _ = cardType, let _ = cardExpireDate, let _ = cardCVC2 {
            return true
        }
        return false
    }
}
