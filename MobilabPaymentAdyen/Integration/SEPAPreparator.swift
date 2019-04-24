//
//  SEPAPreparator.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import AdyenSEPA
import Foundation
import MobilabPaymentCore

struct SEPAPreparator: PaymentMethodPreparator {
    let paymentMethodType: String = "sepadirectdebit"
    let billingData: BillingData?
    let sepaData: SEPAAdyenData

    func preparedPaymentMethod(from paymentMethods: SectionedPaymentMethods, for _: PaymentController) -> PaymentMethod? {
        guard let paymentMethod = (paymentMethods.preferred + paymentMethods.other)
            .first(where: { $0.type == self.paymentMethodType })
        else { return nil }

        var method = paymentMethod
        method.details.sepaIBAN?.value = sepaData.ibanNumber
        method.details.sepaName?.value = sepaData.ownerName

        return method
    }
}
