//
//  CreditCardPreparator.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
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
            number: creditCardData.number,
            securityCode: creditCardData.cvc,
            expiryMonth: creditCardData.expiryMonth,
            expiryYear: creditCardData.expiryYear
        )

        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)

        var method = paymentMethod
        method.details.cardholderName?.value = billingData?.name
        method.details.encryptedCardNumber?.value = encryptedCard.number
        method.details.encryptedSecurityCode?.value = encryptedCard.securityCode
        method.details.encryptedExpiryMonth?.value = encryptedCard.expiryMonth
        method.details.encryptedExpiryYear?.value = encryptedCard.expiryYear

        return method
    }
}
