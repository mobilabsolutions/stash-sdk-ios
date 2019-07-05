//
//  NecessaryData.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public enum NecessaryData: CaseIterable {
    case holderFullName
    case holderFirstName
    case holderLastName
    case cardNumber
    case cvv
    case expirationMonth
    case expirationYear
    case iban
    case bic
    case country
}
