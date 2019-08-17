//
//  PaymentMethodPreparator.swift
//  StashAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Adyen

protocol PaymentMethodPreparator {
    var paymentMethodType: String { get }
    func preparedPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController) -> PaymentMethod?
}
