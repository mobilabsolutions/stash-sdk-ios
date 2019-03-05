//
//  RegisterCreditCardRequest.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct RegisterCreditCardRequest: Codable {
    
    var creditCardNumber: String
    
    public init(creditCardNumber: String) {
        self.creditCardNumber = creditCardNumber
    }
    
}
