//
//  AdditionalRegistrationData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct AdditionalRegistrationData {
    var data: [String: String]

    init(data: [String: String]) {
        self.data = data
    }
}
