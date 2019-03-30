//
//  RouterRequestBSPayone.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

enum RouterServiceAdyen {
    case registerCreditCard(CreditCardAdyenData)
    case registerSEPA(SEPAAdyenData)
}

struct RouterRequestAdyen: RouterRequestProtocol {
    let service: RouterServiceAdyen
    let pspData: AdyenData

    func getBaseURL() -> URL {
        return URL(string: "https://checkout-test.adyen.com/v41/payments")!
    }

    func getURL() -> URL {
        let url = self.getBaseURL()
        return url
    }

    func getHttpBody() -> Data? {
        var body: [String: Any] = [
            "amount": ["value": 0,
                       "currency": "USD"],
            "reference": "reference",
            "merchantAccount": pspData.merchantAccount,
            "shopperReference": pspData.shopperReference,
            "returnUrl": pspData.returnUrl,
        ]

        switch self.service {
        case let .registerCreditCard(data):

            body["paymentMethod"] = ["type": "scheme",
                                     "number": data.number,
                                     "expiryMonth": data.expiryMonth,
                                     "expiryYear": data.expiryYear,
                                     "cvc": data.cvc,
                                     "holderName": data.holderName,
                                     "storeDetails": true]

        case let .registerSEPA(data):

            body["paymentMethod"] = ["type": "sepadirectdebit",
                                     "sepa.ownerName": data.ownerName,
                                     "sepa.ibanNumber": data.ibanNumber,
                                     "storeDetails": true]
        }

        return try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self.service {
        case .registerCreditCard, .registerSEPA:
            return HTTPMethod.POST
        }
    }

    func getResponseType() -> MLResponseType {
        switch self.service {
        case .registerCreditCard, .registerSEPA:
            return .json
        }
    }

    func getContentTypeHeader() -> String {
        switch self.service {
        case .registerCreditCard, .registerSEPA:
            return "application/json"
        }
    }

    func getHeaders() -> [Header] {
        switch self.service {
        case .registerCreditCard, .registerSEPA:
            return [Header(field: "X-API-key", value: pspData.apiKey)]
        }
    }
}
