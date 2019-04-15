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
    private var billingData: BillingData?
    private var paymentMethodPreparator: PaymentMethodPreparator?
    private var resultCallback: ((Swift.Result<String, Error>) -> Void)?

    private var controller: PaymentController?
    private let tokenForSessionIdExchange: (String) -> Void
    private var sessionIdResponseHandler: Completion<String>?

    init(tokenForSessionIdExchange: @escaping (String) -> Void) {
        self.tokenForSessionIdExchange = tokenForSessionIdExchange
    }

    func start() {
        self.controller = PaymentController(delegate: self)
        self.controller?.start()
    }

    func continueRegistration(sessionId: String,
                              billingData: BillingData?,
                              paymentMethodPreparator: PaymentMethodPreparator,
                              resultCallback: @escaping (Swift.Result<String, Error>) -> Void) {
        self.billingData = billingData
        self.paymentMethodPreparator = paymentMethodPreparator
        self.resultCallback = resultCallback

        self.sessionIdResponseHandler?(sessionId)
    }

    func requestPaymentSession(withToken token: String, for _: PaymentController, responseHandler: @escaping Completion<String>) {
        self.tokenForSessionIdExchange(token)
        self.sessionIdResponseHandler = responseHandler
    }

    func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping Completion<PaymentMethod>) {
        guard let method = self.paymentMethodPreparator?.preparedPaymentMethod(from: paymentMethods, for: paymentController)
        else { self.resultCallback?(.failure(MLError(description: "Payment method type not supported by PSP", code: 1234))); return }

        selectionHandler(method)
    }

    func redirect(to _: URL, for _: PaymentController) {
        #warning("Do something here")
    }

    func didFinish(with result: Adyen.Result<PaymentResult>, for _: PaymentController) {
        switch result {
        case let .success(result):
            self.resultCallback?(.success(result.payload))
        case let .failure(error):
            self.resultCallback?(.failure(error))
        }
    }

    func provideAdditionalDetails(_: AdditionalPaymentDetails, for _: PaymentMethod, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        #warning("Potentially implement this")
        detailsHandler([])
    }
}
