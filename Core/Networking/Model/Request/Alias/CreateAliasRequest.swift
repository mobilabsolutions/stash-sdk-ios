//
//  CreateAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct CreateAliasRequest: Codable {
    
    var pspIdentifier: String
    var mask: String
    
    init(pspIdentifier: String, mask: String) {
        self.pspIdentifier = pspIdentifier
        self.mask = mask
    }
    
}
