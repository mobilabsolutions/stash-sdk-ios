//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

protocol MLNetworkClient {
    
    typealias SuccessCompletion<T> = ((T) -> Void)?
    typealias FailureCompletion = ((MLError) -> Void)?
    typealias Completion<T> = ((MLResult<T, MLError>) -> Void)
    
    func fetch<T: Decodable>(with request: RouterRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (MLResult<T, MLError>) -> Void)
    func addMethod(paymentMethod: MLPaymentMethod, success: SuccessCompletion<String>, failiure: FailureCompletion)
}

//MARK: Shared methods
extension MLNetworkClient {

    typealias JSONTaskCompletionHandler = (Decodable?, MLError?) -> Void
    
    private func decodingData<T: Decodable>(with data: Data, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) {
        
        do {
            let genericModel = try JSONDecoder().decode(decodingType, from: data)
            completion(genericModel, nil)
        } catch {
            let err = MLError(title: "Decoding error", description: "Decoding error", code: 1)
            completion(nil, err)
        }

    }
    
    func fetch<T: Decodable>(with request: RouterRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (MLResult<T, MLError>) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        let urlRequest = request.asURLRequest()
        print("API request: \(urlRequest.url!)")
        
        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                if let err = error as NSError? {
                    completion(.failure(MLError(title: "API error", description: err.localizedDescription, code: err.code)))
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
                else {
                    let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                    completion(.failure(err))
                    print("error: not a valid http response")
                    return
            }
            
            switch (httpResponse.statusCode)
            {
            case 200:
                
                switch request.getResponseType() {
                case .json:
                    
                    self.decodingData(with: receivedData, decodingType: T.self, completionHandler: { (result, error) in
 
                        guard let decodable = result else {
                            completion(.failure(error!))
                            return
                        }
                        
                        if let value = decode(decodable) {
                            completion(.success(value))
                        } else {
                            let err = MLError(title: "Decoding error", description: "Decoding error", code: 2)
                            completion(.failure(err))
                        }
                        
                    })

                case .xml:
                    //TODO implement
                    let err = MLError(title: "XML implementation needed", description: "XML implementation needed", code: 1)
                    completion(.failure(err))
                }
                
                break
            default:
                print(String(data: receivedData, encoding: String.Encoding.utf8) ?? "Decoding received data failed")
                print("Got error, status code:  \(httpResponse.statusCode)")
                let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                completion(.failure(err))
            }
        }
        dataTask.resume()
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
