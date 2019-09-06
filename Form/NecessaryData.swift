//
//  NecessaryData.swift
//  StashBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Data that a PSP might need and which should be collected directly from the user
public enum NecessaryData: CaseIterable {
    /// The payment method holder's full name
    case holderFullName
    /// The payment method holder's first name
    case holderFirstName
    /// The payment method holder's last name
    case holderLastName
    /// The credit card number
    case cardNumber
    /// The CVV
    case cvv
    /// The payment method expiration month
    case expirationMonth
    /// The payment method expiration year
    case expirationYear
    /// The IBAN for SEPA methods
    case iban
    /// The BIC for SEPA methods
    case bic
    /// The user or payment method country
    case country
}
