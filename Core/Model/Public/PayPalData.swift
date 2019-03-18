//
//  PayPalData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 14/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PayPalData: RegistrationData {
    public let nounce: String

    public init(nounce: String) {
        self.nounce = nounce
    }
}
