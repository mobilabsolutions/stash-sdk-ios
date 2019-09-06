//
//  CreditCardPreparator.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

struct BSPayoneCreditCardExtraPreparator: CreditCardExtraPreparatorProtocol {
    let creditCardData: CreditCardData

    func prepare() throws -> CreditCardExtra {
        return CreditCardExtra(ccExpiry: "\(String(format: "%02d", self.creditCardData.expiryMonth))/\(String(format: "%02d", self.creditCardData.expiryYear))",
                               ccMask: self.creditCardData.cardMask,
                               ccType: self.creditCardData.cardType.rawValue,
                               ccHolderName: self.creditCardData.billingData.name?.fullName)
    }
}
