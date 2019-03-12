//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

public protocol NetworkClient {
    typealias Completion<T> = ((NetworkClientResult<T, MLError>) -> Void)
    func fetch<T: Decodable>(with request: RouterRequestProtocol, responseType: T.Type, completion: @escaping Completion<T>)
}

public extension NetworkClient {
    typealias DecodingDataCompletionHandler = (Decodable?, MLError?) -> Void

    func fetch<T: Decodable>(with request: RouterRequestProtocol, responseType _: T.Type, completion: @escaping Completion<T>) {
        let configuration = URLSessionConfiguration.default
        let urlRequest = request.asURLRequest()

        #warning("Optimize logging: e.g. only log on a certain flag")
        if let method = urlRequest.httpMethod, let url = urlRequest.url {
            print("API request: \(method) \(url)")
        }

        if let bodyData = urlRequest.httpBody, let body = bodyData.toJSONString() {
            print(body)
        }

        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in

            if error != nil {
                if let err = error as NSError? {
                    completion(.failure(MLError(title: "API error", description: err.localizedDescription, code: err.code)))
                    return
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
            else {
                let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                completion(.failure(err))
                print("error: not a valid http response")
                return
            }

            switch httpResponse.statusCode {
            case 200, 201, 204:

                switch request.getResponseType() {
                case .json:

                    guard receivedData.count != 0 else {
                        completion(.success(true as! T))
                        return
                    }

                    print(String(data: receivedData, encoding: String.Encoding.utf8) ?? "Decoding received data failed")

                    self.decodingData(with: receivedData, decodingType: T.self, completionHandler: { result, error in

                        guard let decodable = result, let castedDecodable = decodable as? T else {
                            completion(.failure(error!))
                            return
                        }

                        completion(.success(castedDecodable))
                    })

                case .xml:
                    // TODO: implement
                    let err = MLError(title: "XML implementation needed", description: "XML implementation needed", code: 1)
                    completion(.failure(err))
                }

            default:
                print(String(data: receivedData, encoding: String.Encoding.utf8) ?? "Decoding received data failed")
                print("Got error, status code:  \(httpResponse.statusCode)")
                let err = MLError(title: "Not a valid http response", description: "Not a valid http response", code: 1)
                completion(.failure(err))
            }
        }
        dataTask.resume()
    }

    private func decodingData<T: Decodable>(with data: Data, decodingType: T.Type, completionHandler completion: @escaping DecodingDataCompletionHandler) {
        do {
            let genericModel = try JSONDecoder().decode(decodingType, from: data)
            completion(genericModel, nil)
        } catch {
            let err = MLError(title: "Decoding error", description: "Decoding error", code: 1)
            completion(nil, err)
        }
    }
}
