//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

private enum ApiError<S: MLErrorConvertible>: Error, MLErrorConvertible {
    case requestFailed(Int, String)
    case apiErrorResponse(S)
    case responseNotValid
    case unknown

    func toMLError() -> MLError {
        switch self {
        case let .requestFailed(code, localizedDescription):
            return MLError(description: localizedDescription, code: code)
        case .responseNotValid:
            return MLError(description: "Response not valid", code: 1)
        case let .apiErrorResponse(error):
            return error.toMLError()
        case .unknown:
            return MLError(description: "Unknown error", code: 2)
        }
    }
}

public enum NetworkClientError: Error {
    case shouldTryDecodingErrorResponse
}

public protocol NetworkClient {
    typealias Completion<T> = ((Result<T, MLError>) -> Void)
    func fetch<T: Decodable, S: Decodable & MLErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>)
}

public extension NetworkClient {
    typealias DecodingDataCompletionHandler = (Decodable?, MLError?) -> Void

    func fetch<T: Decodable, S: Decodable & MLErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>) {
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
                let decoded = try self.handleResponse(data: data, response: response, error: error, decodingType: responseType, errorType: errorType)
                completion(.success(decoded))
            } catch let errorType as ApiError<S> {
                completion(.failure(errorType.toMLError()))
            } catch {
                completion(.failure(ApiError<S>.unknown.toMLError()))
            }
        }
        dataTask.resume()
    }

    private func handleResponse<T: Decodable, S: MLErrorConvertible & Decodable>(data: Data?, response: URLResponse?, error: Error?,
                                                                                 decodingType: T.Type, errorType: S.Type?) throws -> T {
        if let error = error as NSError? {
            throw ApiError<S>.requestFailed(error.code, error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse, let receivedData = data else {
            throw ApiError<S>.responseNotValid
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
            } catch NetworkClientError.shouldTryDecodingErrorResponse {
                fallthrough
            } catch {
                throw ApiError<S>.responseNotValid
            }

        default:
            if let type = errorType, let answer = try? JSONDecoder().decode(type, from: receivedData) {
                throw ApiError<S>.apiErrorResponse(answer)
            }
            throw ApiError<S>.responseNotValid
        }
    }
}
