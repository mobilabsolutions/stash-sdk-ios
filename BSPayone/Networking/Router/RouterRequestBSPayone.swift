//
//  RouterRequestBSPayone.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

enum RouterServiceBSPayone {
    case registerCreditCard(CreditCardBSPayoneData, PSPExtra)
}

struct RouterRequestBSPayone: RouterRequestProtocol {
    let service: RouterServiceBSPayone

    func getBaseURL() -> URL {
        return URL(string: "https://secure.pay1.de/client-api/")!
    }

    func getURL() -> URL {
        switch self.service {
        case let .registerCreditCard(creditCardData, pspData):

            let url = self.getBaseURL().append("mid", value: pspData.merchantId)
                .append("portalid", value: pspData.portalId)
                .append("api_version", value: pspData.apiVersion)
                .append("mode", value: "test")
                .append("request", value: pspData.request)
                .append("responsetype", value: pspData.responseType)
                .append("hash", value: "35996f45100c40d51cffedcddc471f8189fc3568c287871568dc6c8bae1c4d732ded416b502f6191fb6085a2d767ef6f")

                .append("aid", value: pspData.accountId)
                .append("cardpan", value: creditCardData.cardPan)
                .append("cardtype", value: creditCardData.cardType)
                .append("cardexpiredate", value: creditCardData.cardExpireDate)
                .append("cardcvc2", value: creditCardData.cardCVC2)
                .append("storecarddata", value: "yes")

            return url
        }
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self.service {
        case .registerCreditCard:
            return HTTPMethod.GET
        }
    }

    func getResponseType() -> MLResponseType {
        switch self.service {
        case .registerCreditCard:
            return .json
        }
    }

    func getContentTypeHeader() -> String {
        switch self.service {
        case .registerCreditCard:
            return "application/json"
        }
    }

    func getAuthorizationHeader() -> String {
        switch self.service {
        case .registerCreditCard:
            // let token = MLConfigurationBuilder.sharedInstance.configuration?.publicToken
            // return "Bearer \(token!.toBase64())"
            return ""
        }
    }
}
