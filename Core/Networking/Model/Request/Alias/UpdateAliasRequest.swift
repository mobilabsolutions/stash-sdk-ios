//
//  UpdateAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct UpdateAliasRequest: Codable {
    
    var aliasId: String
    var billingData: String // needs to be changed
    
    init(aliasId: String, billingData: String) {
        self.aliasId = aliasId
        self.billingData = billingData
    }
    
}
