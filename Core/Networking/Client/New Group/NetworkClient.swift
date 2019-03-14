//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

private enum ApiError: Error {
    case requestFailed(Int, String)
    case responseNotValid
    case decodingFailed
    case unknown

    func createError() -> MLError {
        switch self {
        case let .requestFailed(code, localizedDescription):
            return MLError(description: localizedDescription, code: code)
        case .responseNotValid:
            return MLError(description: "Response not valid", code: 1)
        case .decodingFailed:
            return MLError(description: "API decoding failed", code: 2)
        case .unknown:
            return MLError(description: "Unknown error", code: 3)
        }
    }
}

public protocol NetworkClient {
    typealias Completion<T> = ((NetworkClientResult<T, MLError>) -> Void)
    func fetch<T: Decodable>(with request: RouterRequestProtocol, responseType: T.Type, completion: @escaping Completion<T>)
}

public extension NetworkClient {
    typealias DecodingDataCompletionHandler = (Decodable?, MLError?) -> Void

    func fetch<T: Decodable>(with request: RouterRequestProtocol, responseType: T.Type, completion: @escaping Completion<T>) {
        let urlRequest = request.asURLRequest()

        let isLoggingEnabled = InternalPaymentSDK.sharedInstance.configuration.loggingEnabled
        if isLoggingEnabled, let method = urlRequest.httpMethod, let url = urlRequest.url {
            print("MobilabPayment request: \(method) \(url)")
            #if DEBUG
                if let bodyData = urlRequest.httpBody, let body = bodyData.toJSONString() {
                    print(body)
                }
            #endif
        }

        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                let decoded = try self.handleResponse(data: data, response: response, error: error, decodingType: responseType)
                completion(.success(decoded))
            } catch let errorType as ApiError {
                completion(.failure(errorType.createError()))
            } catch {
                completion(.failure(ApiError.unknown.createError()))
            }
        }
        dataTask.resume()
    }

    private func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, decodingType: T.Type) throws -> T {
        guard error == nil else {
            if let error = error as NSError? {
                throw ApiError.requestFailed(error.code, error.localizedDescription)
            }
            fatalError("This should not happen")
        }

        guard let httpResponse = response as? HTTPURLResponse, let receivedData = data else {
            throw ApiError.responseNotValid
        }

        let isLoggingEnabled = InternalPaymentSDK.sharedInstance.configuration.loggingEnabled
        if isLoggingEnabled, let receivedData = receivedData.toJSONString() {
            #if DEBUG
                print(receivedData)
            #endif
        }

        switch httpResponse.statusCode {
        case 200, 201, 204:

            guard receivedData.count != 0 else {
                return true as! T
            }

            do {
                return try JSONDecoder().decode(decodingType, from: receivedData)
            } catch {
                throw ApiError.decodingFailed
            }

        default:
            throw ApiError.responseNotValid
        }
    }
}
