//
//  RouterRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 18/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation
import ObjectMapper

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}

enum MLResponseType {
    case xml
    case json
}

enum RouterRequest {
    case addCreditCard(MLCreditCardRequest)
    case addSEPA(MLSEPARequest)
    case updatePanAlias(MLUpdatePanaliasRequest)
    
    //BS directly methods
    case bsRegisterCreditCard(MLPaymentMethod, MLAddCreditCardResponseBS)
    case bsFetchMethodAlias(MLPaymentMethod, MLAddCreditCardResponseBS)
    
    //HC directly methods
    case hcRegisterCreditCard(MLPaymentMethod, MLAddCreditCardResponseHC)
    
}

// MARK: Public methods
extension RouterRequest {
    
    func asURLRequest() -> URLRequest {
        return buildRequest(url: getURL()) 
    }
    
    func getResponseType() -> MLResponseType {
        switch self {
        case .addCreditCard(_),
             .addSEPA(_),
             .updatePanAlias(_):
            return .json
        case .bsRegisterCreditCard(_, _),
             .bsFetchMethodAlias(_, _),
             .hcRegisterCreditCard(_,_):
            return .xml
        }
    }
}
    
// MARK: Private methods
extension RouterRequest {
    func buildRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = getHTTPMethod().rawValue
        urlRequest.timeoutInterval = getTimeOut()
        if withBody() {
            urlRequest.httpBody = getHttpBody()
        }
        
        urlRequest.addValue(getContentTypeHeader(), forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(getAuthorizationHeader(), forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    func withBody() -> Bool {
        let method = getHTTPMethod()
        return method == .POST || method == .PUT
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
        switch self {
        case .addCreditCard(_),
             .addSEPA(_),
             .updatePanAlias(_):
            return getBaseURL()
            
        case .bsRegisterCreditCard(_, let creditCardResponse),
             .bsFetchMethodAlias(_, let creditCardResponse):
            return URL(string: creditCardResponse.url)!
            
        case .hcRegisterCreditCard(_,let creditCardResponse):
            return URL(string: creditCardResponse.url)!
        }
    }
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {  
        case .addCreditCard(_),
             .addSEPA(_),
            .bsRegisterCreditCard(_,_),
            .bsFetchMethodAlias(_,_),
            .hcRegisterCreditCard(_,_):
                return HTTPMethod.POST
        case .updatePanAlias(_):
            return HTTPMethod.PUT
        }
    }
    
    func getTimeOut() -> Double {
        switch self {
        default: return 10
        }
    }
}
