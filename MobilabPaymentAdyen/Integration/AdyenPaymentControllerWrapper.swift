//
//  AdyenPaymentControllerWrapper.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 09.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
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
    private let providerIdentifier: String

    init(providerIdentifier: String, tokenForSessionIdExchange: @escaping (String) -> Void) {
        self.tokenForSessionIdExchange = tokenForSessionIdExchange
        self.providerIdentifier = providerIdentifier
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
        else {
            let error = MobilabPaymentError.configuration(.providerNotSupportingPaymentMethod(provider: self.providerIdentifier,
                                                                                              paymentMethod: self.paymentMethodPreparator?.paymentMethodType ?? "Unknown"))
            self.resultCallback?(.failure(error))
            return
        }

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
