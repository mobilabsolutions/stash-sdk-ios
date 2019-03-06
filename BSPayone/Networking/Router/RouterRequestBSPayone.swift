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
    case registerCreditCard(RegisterCreditCardRequest)
}

struct RouterRequestBSPayone: RouterRequestProtocol {
    var service: RouterServiceBSPayone

    init(service: RouterServiceBSPayone) {
        self.service = service
    }

    func getBaseURL() -> URL {
        var url = URL(string: "url")!
        if let relativePath = getRelativePath() {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }

    func getURL() -> URL {
        switch self.service {
        case .registerCreditCard:
            return self.getBaseURL()
        }
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self.service {
        case .registerCreditCard:
            return HTTPMethod.POST
        }
    }

    func getResponseType() -> MLResponseType {
        switch self.service {
        case .registerCreditCard:
            return .json
        }
    }

    func getHttpBody() -> Data? {
        switch self.service {
        case let .registerCreditCard(data):
            return try? JSONEncoder().encode(data)
        }
    }

    func getRelativePath() -> String? {
        switch self.service {
        case .registerCreditCard:
            return "v2/alias"
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

    func getCustomHeader() -> Header? {
        return nil
    }
}
