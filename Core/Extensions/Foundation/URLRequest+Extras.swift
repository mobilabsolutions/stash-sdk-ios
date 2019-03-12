//
//  URLRequest+Extras.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func addHeader(customHeader: Header?) {
        if let header = customHeader {
            addValue(header.value, forHTTPHeaderField: header.field)
        }
    }
}
