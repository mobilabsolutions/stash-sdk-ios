//
//  CreditCardExtra.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct CreditCardExtra: Codable {
    public let ccExpiry: String
    public let ccMask: Int
    public let ccType: String
    public let ccHolderName: String?

    public init(ccExpiry: String, ccMask: Int, ccType: String, ccHolderName: String?) {
        self.ccExpiry = ccExpiry
        self.ccMask = ccMask
        self.ccType = ccType
        self.ccHolderName = ccHolderName
    }
}
