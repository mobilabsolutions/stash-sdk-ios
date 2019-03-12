//
//  RouterRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 18/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
}

public enum MLResponseType {
    case xml
    case json
}

public protocol RouterRequestProtocol {
    func getBaseURL() -> URL
    func getURL() -> URL
    func getHTTPMethod() -> HTTPMethod
    func getContentTypeHeader() -> String
    func getHttpBody() -> Data?
    func getAuthorizationHeader() -> String
    func getRelativePath() -> String?
    func getResponseType() -> MLResponseType
    func asURLRequest() -> URLRequest
    func getTimeOut() -> Double
    func getCustomHeader() -> Header?
}

// MARK: Public methods

public extension RouterRequestProtocol {
    func asURLRequest() -> URLRequest {
        return buildRequest(url: getURL())
    }

    func getTimeOut() -> Double {
        switch self {
        default: return 10
        }
    }

    func getHttpBody() -> Data? {
        return nil
    }

    func getRelativePath() -> String? {
        return nil
    }

    func getCustomHeader() -> Header? {
        return nil
    }
}

// MARK: Private methods

extension RouterRequestProtocol {
    func buildRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = getHTTPMethod().rawValue
        urlRequest.timeoutInterval = getTimeOut()
        if self.withBody() {
            urlRequest.httpBody = self.getHttpBody()
        }

        urlRequest.addValue(getContentTypeHeader(), forHTTPHeaderField: "Content-Type")
        urlRequest.addHeader(customHeader: self.getCustomHeader())
        urlRequest.addValue(getAuthorizationHeader(), forHTTPHeaderField: "Public-Key")
        return urlRequest
    }

    func withBody() -> Bool {
        let method = getHTTPMethod()
        return method == .POST || method == .PUT
    }
}
