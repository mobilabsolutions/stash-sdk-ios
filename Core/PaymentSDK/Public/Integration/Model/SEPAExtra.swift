//
//  SEPAExtra.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct SEPAExtra: Codable {
    public let iban: String
    public let bic: String?
}
