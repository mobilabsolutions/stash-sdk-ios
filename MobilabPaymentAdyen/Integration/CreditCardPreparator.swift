//
//  CreditCardPreparator.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import AdyenCard
import Foundation
import MobilabPaymentCore

struct CreditCardPreparator: PaymentMethodPreparator {
    let paymentMethodType: String = "card"
    let billingData: BillingData?
    let creditCardData: CreditCardAdyenData

    func preparedPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController) -> PaymentMethod? {
        guard let paymentMethod = (paymentMethods.preferred + paymentMethods.other)
            .first(where: { $0.type == self.paymentMethodType })
        else { return nil }

        guard let publicKey = paymentController.paymentSession?.publicKey,
            let generationDate = paymentController.paymentSession?.generationDate
        else { return nil }

        let card = CardEncryptor.Card(
            number: self.creditCardData.number,
            securityCode: self.creditCardData.cvc,
            expiryMonth: self.creditCardData.expiryMonth,
            expiryYear: self.creditCardData.expiryYear
        )

        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)

        var method = paymentMethod
        method.details.cardholderName?.value = self.billingData?.name?.fullName
        method.details.encryptedCardNumber?.value = encryptedCard.number
        method.details.encryptedSecurityCode?.value = encryptedCard.securityCode
        method.details.encryptedExpiryMonth?.value = encryptedCard.expiryMonth
        method.details.encryptedExpiryYear?.value = encryptedCard.expiryYear

        return method
    }
}
