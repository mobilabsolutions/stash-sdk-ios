//
//  RouterRequestCore.swift
//  StashCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

enum RouterServiceCore {
    case createAlias(CreateAliasRequest)
    case updateAlias(UpdateAliasRequest)
    case verifyAlias(VerifyAliasRequest)

    var idempotencyKey: String {
        switch self {
        case let .createAlias(request):
            return request.idempotencyKey
        case let .updateAlias(request):
            return request.idempotencyKey
        case let .verifyAlias(request):
            return request.idempotencyKey
        }
    }
}

struct RouterRequestCore: RouterRequestProtocol {
    let service: RouterServiceCore

    init(service: RouterServiceCore) {
        self.service = service
    }

    func getBaseURL() -> URL {
        var url = InternalPaymentSDK.sharedInstance.networkingClient.endpoint
        if let relativePath = getRelativePath() {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }

    func getURL() -> URL {
        switch self.service {
        case .createAlias,
             .updateAlias,
             .verifyAlias:
            return self.getBaseURL()
        }
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self.service {
        case .createAlias, .verifyAlias:
            return HTTPMethod.POST
        case .updateAlias:
            return HTTPMethod.PUT
        }
    }

    func getHttpBody() -> Data? {
        switch self.service {
        case let .createAlias(request):
            return request.aliasDetail.flatMap { try? JSONEncoder().encode($0) }

        case let .updateAlias(data):
            return try? JSONEncoder().encode(data)
        case let .verifyAlias(data):
            return try? JSONEncoder().encode(data)
        }
    }

    func getRelativePath() -> String? {
        switch self.service {
        case .createAlias:
            return "/alias"
        case let .updateAlias(request):
            return "/alias/\(request.aliasId)"
        case let .verifyAlias(request):
            return "/alias/\(request.aliasId)/verify"
        }
    }

    func getContentTypeHeader() -> String {
        switch self.service {
        case .createAlias,
             .updateAlias,
             .verifyAlias:
            return "application/json"
        }
    }

    func getAuthorizationHeader() -> String {
        switch self.service {
        case .createAlias,
             .updateAlias,
             .verifyAlias:
            return InternalPaymentSDK.sharedInstance.configuration.publishableKey
        }
    }

    func getHeaders() -> [Header] {
        var headers = [
            Header(field: "Publishable-Key", value: InternalPaymentSDK.sharedInstance.configuration.publishableKey),
            Header(field: "User-Agent", value: "iOS-\(InternalPaymentSDK.sharedInstance.version)"),
        ]

        if InternalPaymentSDK.sharedInstance.configuration.useTestMode {
            headers.append(Header(field: "PSP-Test-Mode", value: "true"))
        }

        switch self.service {
        case let .createAlias(request):
            headers.append(Header(field: "PSP-Type", value: request.pspType))
            headers.append(Header(field: "Idempotent-Key", value: self.service.idempotencyKey))
            return headers
        case .updateAlias:
            return headers
        case .verifyAlias:
            return headers
        }
    }

    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
