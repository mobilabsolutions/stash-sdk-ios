//
//  CreditCardExtra.swift
//  StashCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A model that contains all extra information that should be
/// propagated to the payment SDK backend when registering a credit card.
/// This will and should not be used by clients directly but only by
/// the core SDK and modules.
public struct CreditCardExtra: Codable {
    /// The card expiry date in the form MM/YY
    public let ccExpiry: String
    /// The card mask: last four digits of the card number
    public let ccMask: String
    /// The type of credit card that is registered (e.g. VISA or MasterCard)
    public let ccType: String
    /// The name of the credit card holder.
    public let ccHolderName: String?

    public init(ccExpiry: String, ccMask: String, ccType: String, ccHolderName: String?) {
        self.ccExpiry = ccExpiry
        self.ccMask = ccMask
        self.ccType = ccType
        self.ccHolderName = ccHolderName
    }
}
