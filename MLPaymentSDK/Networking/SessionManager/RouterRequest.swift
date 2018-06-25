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
    static let baseURLString = "https://pd.mblb.net/api/v1"
    
    case addCreditCardBS(MLCreditCardRequest)
    case addSEPABS(MLCreditCardRequest)
    case addCreditCardHC(MLCreditCardRequest)
    case addSEPAHC(MLCreditCardRequest)
    case updatePanAlias(MLUpdatePanaliasRequest)
    
    //BS directly methods
    case bsRegisterCreditCard(MLPaymentMethod, MLAddCreditCardResponseBS)
    case bsFetchMethodAlias(MLPaymentMethod, MLAddCreditCardResponseBS)
    
}

// MARK: Public methods
extension RouterRequest {
    
    func asURLRequest() -> URLRequest {
        return buildRequest(url: getURL()) 
    }
    
    func getResponseType() -> MLResponseType {
        switch self {
        case .addCreditCardBS(_),
             .addCreditCardHC(_),
             .addSEPABS(_),
             .addSEPAHC(_),
             .updatePanAlias(_):
            return .json
        case .bsRegisterCreditCard(_, _),
             .bsFetchMethodAlias(_, _):
            return .xml
            
        }
    }
}
    
// MARK: Private methods
private extension RouterRequest {
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
    
    func getAuthorizationHeader() -> String {
        switch self {
        case .addCreditCardBS(_),
             .addCreditCardHC(_),
             .addSEPABS(_),
             .addSEPAHC(_),
             .updatePanAlias(_):
            return "Bearer UEQtQlMtZWlYRGJlM2oweml4SlVwV0FndmgzY1M0SHo="
        case .bsRegisterCreditCard(_, let creditCardResponse),
             .bsFetchMethodAlias(_, let creditCardResponse):
            let data = "\(creditCardResponse.username):\(creditCardResponse.password)".data(using: getEncoding())
            if let encodedData = data?.base64EncodedString() {
               return "Basic \(encodedData)"
            }
            return ""
        }
    }
    
    func getBaseURL() -> URL {
        var url = URL(string: RouterRequest.baseURLString)!
        if let relativePath = getRelativePath() {
            url = url.appendingPathComponent(relativePath)
        }
        return url
    }
    
    func getURL() -> URL {
        
        switch self {
        case .addCreditCardBS(_),
             .addCreditCardHC(_),
             .addSEPABS(_),
             .addSEPAHC(_),
             .updatePanAlias(_):
            return getBaseURL()
            
        case .bsRegisterCreditCard(_, let creditCardResponse),
             .bsFetchMethodAlias(_, let creditCardResponse):
            return URL(string: creditCardResponse.url)!
        }
    }
    
    func getRelativePath() -> String? {

        switch self {
        
        case .addCreditCardBS(_), .addCreditCardHC(_):
            return "register/creditcard"
        case .addSEPABS(_), .addSEPAHC(_):
            return "register/sepa"
        case .updatePanAlias(_):
            return "update/panalias"
            
        case .bsRegisterCreditCard(_,_),
             .bsFetchMethodAlias(_,_):
            return ""
            
        }
    }
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
            
        case .addCreditCardBS(_),
             .addCreditCardHC(_),
             .addSEPABS(_),
             .addSEPAHC(_),
            .bsRegisterCreditCard(_,_),
            .bsFetchMethodAlias(_,_):
                return HTTPMethod.POST
        case .updatePanAlias(_):
            return HTTPMethod.PUT
        }
    }
    
    func getContentTypeHeader() -> String {
        switch self {
        case .addCreditCardBS(_),
             .addCreditCardHC(_),
             .addSEPABS(_),
             .addSEPAHC(_),
             .updatePanAlias(_):
            return "application/json"
        case .bsRegisterCreditCard(_,_),
             .bsFetchMethodAlias(_,_):
            return "application/soap+xml"
        }
    }
    
    func getHttpBody() -> Data? {
        switch self {
        case .addCreditCardBS(let data),
             .addCreditCardHC(let data),
             .addSEPABS(let data),
             .addSEPAHC(let data):
            let json = Mapper().toJSONString(data, prettyPrint: true)
            return json?.data(using: getEncoding())
        
        case .updatePanAlias(let data):
            let json = Mapper().toJSONString(data, prettyPrint: true)
            return json?.data(using: getEncoding())
        
        case .bsRegisterCreditCard(let method,let creditCard):
            guard let xmlStr = creditCard.serializeXML(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
            
        case .bsFetchMethodAlias(let method, let creditCard):
            guard let xmlStr = creditCard.serializeXMLForAlias(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
        }
    }

    func getTimeOut() -> Double {
        switch self {
        default: return 10
        }
    }
    
    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
