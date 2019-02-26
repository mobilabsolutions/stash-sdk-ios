//
//  MLPaymentMethodType.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

enum MLPaymentMethodType: Codable {
    init(from decoder: Decoder) throws {
        try self.init(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try self.encode(to: encoder)
    }
    
    case MLCreditCard
    case MLSEPA
    case MLPayPal
}
