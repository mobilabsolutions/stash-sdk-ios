//
//  AliasExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum PaymentMethod: String, Codable {
    case CC
    case SEPA
    case PAY_PAL
    case GOOGLE_PAY
    case APPLE_PAY
    case KLARNA
}

struct AliasExtra: Codable {
    
    var ccExpiry: String
    var ccMask: String
    var ccType: String
    var email: String
    var ibanMask: String
    var paymentMethod: PaymentMethod
    
}
