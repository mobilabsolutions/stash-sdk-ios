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
    let aId = "42949"
    let cardPan: String
    let cardType: String
    let cardExpireDate: String
    let cardCVC2: String
}
