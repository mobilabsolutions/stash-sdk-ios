//
//  SEPAAdyenData.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 28/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct SEPAAdyenData: Codable {
    let ownerName: String
    let ibanNumber: String
}
