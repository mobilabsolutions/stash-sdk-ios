//
//  PSPExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct PSPExtra: Codable {
    
    var apiVersion: String?
    var encoding: String?
    var hash: String
    var merchantId: String?
    var portalId: String
    var request: String?
    var responseType: String?
    var type: String
    
}
