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
    
    var service:RouterServiceCore
    
    init(service:RouterServiceCore) {
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
        
        switch service {
        case .createAlias(),
             .updateAlias(_):
            return getBaseURL()
        }
        
    }

    func getHTTPMethod() -> HTTPMethod {
        
        switch service {
        case .createAlias():
                return HTTPMethod.POST
        case .updateAlias(_):
            return HTTPMethod.PUT
        }
        
    }

    
    func getResponseType() -> MLResponseType {
        
        switch service {
        case .createAlias(),
             .updateAlias(_):
            return .json
        }
        
    }

    
    func getHttpBody() -> Data? {
        
        switch service {
        case .createAlias():
            return nil

        case .updateAlias(let data):
            return try? JSONEncoder().encode(data)
        }
        
    }
    
    func getRelativePath() -> String? {
        
        switch service {
        case .createAlias():
            return "/alias"
        case .updateAlias(let request):
            return "/alias/"
        }
        
    }
    
    func getContentTypeHeader() -> String {

        switch service {
        case .createAlias(),
             .updateAlias(_):
            return "application/json"

        }
        
    }
    
    func getAuthorizationHeader() -> String {

        switch service {
        case .createAlias(),
             .updateAlias(_):
            return MobilabPaymentConfigurationBuilder.sharedInstance.configuration!.publicToken
        }
        
    }
    
    func getCustomHeader() -> Header? {
        
        switch service {
        case .createAlias():
            let configuration = MobilabPaymentConfigurationBuilder.sharedInstance.configuration!
            return Header(field: "PSP-Type", value: configuration.pspType)
        case .updateAlias(_):
            return nil
        }
        
    }
    
    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
