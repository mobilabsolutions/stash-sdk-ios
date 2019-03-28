//
//  RegisterCreditCardRequest.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public struct CreditCardAdyenData: Codable {
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String
    let holderName: String
}
