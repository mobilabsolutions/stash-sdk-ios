//
//  AdyenPaymentControllerWrapper.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Adyen
import Foundation
import MobilabPaymentCore

class AdyenPaymentControllerWrapper: PaymentControllerDelegate {
    private(set) var controller: PaymentController?
    private let billingData: BillingData?

    private let paymentMethodPreparator: PaymentMethodPreparator
    private let tokenForSessionIdExchange: (String, (String) -> Void) -> Void
    private let resultCallback: (Result<String>) -> Void

    init(paymentMethodPreparator: PaymentMethodPreparator, billingData: BillingData?,
         tokenForSessionIdExchange: @escaping (String, (String) -> Void) -> Void, resultCallback: @escaping (Result<String>) -> Void) {
        self.billingData = billingData
        self.paymentMethodPreparator = paymentMethodPreparator
        self.tokenForSessionIdExchange = tokenForSessionIdExchange
        self.resultCallback = resultCallback
    }

    func start() {
        self.controller = PaymentController(delegate: self)
        self.controller?.start()
    }

    func requestPaymentSession(withToken token: String, for _: PaymentController, responseHandler: @escaping Completion<String>) {
        self.tokenForSessionIdExchange(token, responseHandler)
    }

    func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping Completion<PaymentMethod>) {
        #warning("Handle case where this is nil")
        guard let method = self.paymentMethodPreparator.preparedPaymentMethod(from: paymentMethods, for: paymentController)
        else { return }

        selectionHandler(method)
    }

    func redirect(to _: URL, for _: PaymentController) {
        #warning("Do something here")
    }

    func didFinish(with result: Result<PaymentResult>, for _: PaymentController) {
        switch result {
        case let .success(result):
            self.resultCallback(.success(result.payload))
        case let .failure(error):
            self.resultCallback(.failure(error))
        }
    }

    func provideAdditionalDetails(_: AdditionalPaymentDetails, for _: PaymentMethod, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        #warning("Potentially implement this")
        detailsHandler([])
    }
}
