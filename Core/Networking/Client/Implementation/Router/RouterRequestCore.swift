//
//  RouterRequestCore.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum RouterServiceCore {
    case createAlias()
    case updateAlias(UpdateAliasRequest)
}

struct RouterRequestCore: RouterRequestProtocol {
    var service: RouterServiceCore

    init(service: RouterServiceCore) {
        self.service = service
    }

    func getBaseURL() -> URL {
        let conf = MobilabPaymentConfigurationBuilder.sharedInstance.configuration!
        var url = URL(string: conf.endpoint.rawValue)!
        if let relativePath = getRelativePath() {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }

    func getURL() -> URL {
        switch self.service {
        case .createAlias(),
             .updateAlias:
            return self.getBaseURL()
        }
    }

    func getHTTPMethod() -> HTTPMethod {
        switch self.service {
        case .createAlias():
            return HTTPMethod.POST
        case .updateAlias:
            return HTTPMethod.PUT
        }
    }

    func getResponseType() -> MLResponseType {
        switch self.service {
        case .createAlias(),
             .updateAlias:
            return .json
        }
    }

    func getHttpBody() -> Data? {
        switch self.service {
        case .createAlias():
            return nil

        case let .updateAlias(data):
            return try? JSONEncoder().encode(data)
        }
    }

    func getRelativePath() -> String? {
        switch self.service {
        case .createAlias():
            return "/alias"
        case let .updateAlias(request):
            return "/alias/\(request.aliasId)"
        }
    }

    func getContentTypeHeader() -> String {
        switch self.service {
        case .createAlias(),
             .updateAlias:
            return "application/json"
        }
    }

    func getAuthorizationHeader() -> String {
        switch self.service {
        case .createAlias(),
             .updateAlias:
            return MobilabPaymentConfigurationBuilder.sharedInstance.configuration!.publicToken
        }
    }

    func getCustomHeader() -> Header? {
        switch self.service {
        case .createAlias():
            let configuration = MobilabPaymentConfigurationBuilder.sharedInstance.configuration!
            return Header(field: "PSP-Type", value: configuration.pspType)
        case .updateAlias:
            return nil
        }
    }

    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
