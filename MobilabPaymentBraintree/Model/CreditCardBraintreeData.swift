//
//  BraintreeCreditCardData.swift
//  MobilabPaymentBraintree
//
//  Created by Biju Parvathy on 06.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import MobilabPaymentCore

/// The Braintree PSP data that is returned by the createAlias call
struct CreditCardBraintreeData {
    /// Client token used for initializing Braintree SDK
    public let clientToken: String
    let cardPan: String
    let expirationMonth: String
    let expirationYear: String
    let cardCVC2: String
}
