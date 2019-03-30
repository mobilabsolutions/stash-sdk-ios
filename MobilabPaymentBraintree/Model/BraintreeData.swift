//
//  BraintreeData.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 30/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct BraintreeData: Codable {
    /// Client token used for initializing Braintree SDK
    public let clientToken: String
}
