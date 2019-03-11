//
//  RegisterCreditCardRequest.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public struct CreditCardBSPayoneData {
    let aId: String = "42949"
    let cardPan: String?
    let cardType: String?
    let cardExpireDate: String?
    let cardCVC2: String?
}

extension CreditCardBSPayoneData: Codable {
    private enum CodingKeys: String, CodingKey {
        case cardPan
        case cardType
        case cardExpireDate
        case cardCVC2
    }

    public static func from(registrationData: Data?) -> CreditCardBSPayoneData {
        guard let data = registrationData, let decoded = try? JSONDecoder().decode(CreditCardBSPayoneData.self, from: data)
        else { fatalError("MobiLabSDK can not decode CreditCardBSPayoneData from data") }
        return decoded
    }

    func isValid() -> Bool {
        if let _ = cardPan, let _ = cardType, let _ = cardExpireDate, let _ = cardCVC2 {
            return true
        }
        return false
    }
}
