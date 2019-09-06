//
//  CreditCardPreparator.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import AdyenCard
import Foundation
import StashCore

struct AdyenCreditCardExtraPreparator: CreditCardExtraPreparatorProtocol {
    private let dateExtractingDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }()

    let creditCardData: CreditCardData
    let cardEncryptionKey: String

    func prepare() throws -> CreditCardExtra {
        guard let date = dateExtractingDateFormatter.date(from: String(format: "%02d", creditCardData.expiryYear))
        else { throw StashError.validation(.invalidExpirationDate) }

        let fullYearComponent = Calendar(identifier: .gregorian).component(.year, from: date)

        let card = CardEncryptor.Card(
            number: self.creditCardData.cardNumber,
            securityCode: self.creditCardData.cvv,
            expiryMonth: String(self.creditCardData.expiryMonth),
            expiryYear: String(fullYearComponent)
        )
        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: self.cardEncryptionKey)

        if let encryptedCardNumber = encryptedCard.number,
            let encryptedCVV = encryptedCard.securityCode,
            let encryptedExpiryMonth = encryptedCard.expiryMonth,
            let encryptedExpiryYear = encryptedCard.expiryYear {
            return CreditCardExtra(ccExpiry: "\(String(format: "%02d", self.creditCardData.expiryMonth))/\(String(format: "%02d", self.creditCardData.expiryYear))",
                                   ccMask: self.creditCardData.cardMask,
                                   ccType: self.creditCardData.cardType.rawValue,
                                   ccHolderName: self.creditCardData.billingData.name?.fullName,
                                   encryptedCardNumber: encryptedCardNumber,
                                   encryptedSecurityCode: encryptedCVV,
                                   encryptedExpiryMonth: encryptedExpiryMonth,
                                   encryptedExpiryYear: encryptedExpiryYear)
        } else {
            throw StashError.configuration(.pspInvalidConfiguration)
        }
    }
}
