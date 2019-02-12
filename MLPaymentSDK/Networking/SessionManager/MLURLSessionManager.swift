//
//  MLURLSessionManager.swift
//  GithubProject
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 Mirza Zenunovic. All rights reserved.
//

import UIKit

enum MLURLResponse {
    case error(MLError?)
    case success(MLURLSessionManager.JSON?)
}

typealias APIClosure = (MLURLResponse) -> Void

class MLURLSessionManager: NSObject {
    
    typealias JSON = [String: Any]
    typealias SuccessCompletion<T> = ((T) -> Void)?
    typealias FailureCompletion = ((MLError) -> Void)?
    
    static func request(request: RouterRequest, success: SuccessCompletion<Any>, failure: FailureCompletion) {
        
        let configuration = URLSessionConfiguration.default
        let urlRequest = request.asURLRequest()
        print("API request: \(urlRequest.url!)")
        
        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: urlRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                
                if error != nil {
                    if let err = error as NSError? {
                        failure?(MLError(title: "API error", description: err.localizedDescription, code: err.code))
                    }
                }
                
                guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                    else {
                        let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                        failure?(err)
                        print("error: not a valid http response")
                        return
                }
                
                switch (httpResponse.statusCode)
                {
                case 200:
                    
                    switch request.getResponseType() {
                    case .json:
                        if let jsonData = try MLURLSessionManager.serializeToJson(data: receivedData) {
                            success?(jsonData)
                        }
                    case .xml:
                        //TODO implement
                        success?(receivedData)
                       // success?(String(data: receivedData, encoding: String.Encoding.utf8))
//                        if let jsonData = try MLURLSessionManager.serializeToJson(data: receivedData) {
//                            success?(jsonData)
//                        }
                    }
                    
                    break
                default:
                    print(String(data: receivedData, encoding: String.Encoding.utf8) ?? "Decoding received data failed")
                    print("Got error, status code:  \(httpResponse.statusCode)")
                    let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                    failure?(err)
                }
            } catch {
                //let responseError = error as? RemoteResourceError ?? RemoteResourceError.generic
                //callBack(.error(error as! MLError))
                let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                failure?(err)
            }
        }
        dataTask.resume()
    }
    
    static func serializeToJson(data: Data) throws -> JSON? {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    
    func validateResponse(response: URLResponse?) throws {
        
        guard let httpResponse = response as? HTTPURLResponse
            else {
                throw MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
        }

        let statusCode = httpResponse.statusCode
        
//        switch statusCode {
//        case 401:
//            throw RemoteResourceError.invalidCredentials
//        case 500..<Int.max:
//            throw RemoteResourceError.server(statusCode: statusCode)
//        case 400..<500:
//            throw RemoteResourceError.request(statusCode: statusCode)
//        case 0:
//            if let urlError = response.error as? URLError {
//                switch urlError.code {
//                case URLError.timedOut:
//                    throw RemoteResourceError.timeout
//                case URLError.notConnectedToInternet, URLError.networkConnectionLost:
//                    throw RemoteResourceError.noInternetConnection
//                default:
//                    throw RemoteResourceError.generic
//                }
//            }
//        default:
//            break
//        }
    }
    
    
    
    
    
}
