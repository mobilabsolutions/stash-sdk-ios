//
//  Header.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct Header {
    var field: String
    var value: String

    init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}
