//
//  RouterRequestCore.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum RouterServiceCore {
    
    case createAlias(CreateAliasRequest)
    case updateAlias(UpdateAliasRequest)
    
}

struct RouterRequestCore: RouterRequestProtocol {
    
    var service:RouterServiceCore
    
    init(service:RouterServiceCore) {
        self.service = service
    }
    
    func getBaseURL() -> URL {
        let conf = MLConfigurationBuilder.sharedInstance.configuration!
        var url = URL(string: conf.endpoint.rawValue)!
        if let relativePath = getRelativePath() {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }
    
    func getURL() -> URL {
        
        switch service {
        case .createAlias(_),
             .updateAlias(_):
            return getBaseURL()
        }
        
    }

    func getHTTPMethod() -> HTTPMethod {
        
        switch service {
        case .createAlias(_):
                return HTTPMethod.POST
        case .updateAlias(_):
            return HTTPMethod.PUT
        }
        
    }

    
    func getResponseType() -> MLResponseType {
        
        switch service {
        case .createAlias(_),
             .updateAlias(_):
            return .json
        }
        
    }

    
    func getHttpBody() -> Data? {
        
        switch service {
        case .createAlias(let data):
            return try? JSONEncoder().encode(data)

        case .updateAlias(let data):
            return try? JSONEncoder().encode(data)
        }
        
    }
    
    func getRelativePath() -> String? {
        
        switch service {
        case .createAlias(_):
            return "v2/alias"
        case .updateAlias(let request):
            return "v2/alias/" + request.aliasId
        }
        
    }
    
    func getContentTypeHeader() -> String {

        switch service {
        case .createAlias(_),
             .updateAlias(_):
            return "application/json"

        }
        
    }
    
    func getAuthorizationHeader() -> String {

        switch service {
        case .createAlias(_),
             .updateAlias(_):
            let token = MLConfigurationBuilder.sharedInstance.configuration?.publicToken
            return "Bearer \(token!.toBase64())"
        }
        
    }
    
    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
