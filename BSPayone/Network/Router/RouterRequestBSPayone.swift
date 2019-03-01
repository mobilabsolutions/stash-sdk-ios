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

    var service:RouterServiceBSPayone
    
    init(service:RouterServiceBSPayone) {
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
        
        switch service {
        case .registerCreditCard(_):
            return getBaseURL()
        }
        
    }
    
    func getHTTPMethod() -> HTTPMethod {
        
        switch service {
        case .registerCreditCard(_):
            return HTTPMethod.POST
        }
        
    }
    
    
    func getResponseType() -> MLResponseType {
        
        switch service {
        case .registerCreditCard(_):
            return .json
        }
        
    }
    
    func getHttpBody() -> Data? {
        
        switch service {
        case .registerCreditCard(let data):
            return try? JSONEncoder().encode(data)
        }
        
    }
    
    func getRelativePath() -> String? {
        
        switch service {
        case .registerCreditCard(_):
            return "v2/alias"
        }
        
    }
    
    func getContentTypeHeader() -> String {
        
        switch service {
        case .registerCreditCard(_):
            return "application/json"
            
        }
        
    }
    
    func getAuthorizationHeader() -> String {
        
        switch service {
        case .registerCreditCard(_):
            //let token = MLConfigurationBuilder.sharedInstance.configuration?.publicToken
            //return "Bearer \(token!.toBase64())"
            return ""
        }
        
    }
}
