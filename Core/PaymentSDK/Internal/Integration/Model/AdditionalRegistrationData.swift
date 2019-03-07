//
//  AdditionalRegistrationData.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct AdditionalRegistrationData {
    public var data: Data?

    init(data: Data?) {
        self.data = data
    }
}
