//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation
#if CORE
#else
    import StashCore
#endif

enum NetworkClientError: Error {
    case shouldTryDecodingErrorResponse
}

protocol NetworkClient {
    typealias Completion<T> = ((Result<T, StashError>) -> Void)
    func fetch<T: Decodable, S: Decodable & StashErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>)
}

/// An error that occurred in the backend
struct StashAPIError<S: StashErrorConvertible>: Error, StashErrorConvertible {
    let error: S

    func toStashError() -> StashError {
        return self.error.toStashError()
    }
}

extension NetworkClient {
    func fetch<T: Decodable, S: Decodable & StashErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>) {
        let urlRequest = request.asURLRequest()

        if let method = urlRequest.httpMethod, let url = urlRequest.url {
            Log.normal(message: "Network request: \(method) \(url)")
            #if DEBUG
                if let bodyData = urlRequest.httpBody, let body = bodyData.toJSONString() {
                    Log.normal(message: body)
                }
            #endif
        }

        let session = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            do {
                let decoded = try self.handleResponse(data: data, response: response, error: error, decodingType: responseType, errorType: errorType)
                completion(.success(decoded))
            } catch let errorType as StashAPIError<S> {
                completion(.failure(errorType.toStashError()))
            } catch let error as StashError {
                completion(.failure(error))
            } catch {
                completion(.failure(StashError.other(GenericErrorDetails.from(error: error))))
            }
        }
        dataTask.resume()
    }

    private func handleResponse<T: Decodable, S: StashErrorConvertible & Decodable>(data: Data?, response: URLResponse?, error: Error?,
                                                                                    decodingType: T.Type, errorType: S.Type?) throws -> T {
        if let error = error as NSError? {
            throw StashError.network(.requestFailed(code: error.code, description: error.localizedDescription)).loggedError()
        }

        guard let httpResponse = response as? HTTPURLResponse, let receivedData = data else {
            throw StashError.network(.responseInvalid).loggedError()
        }

        if let receivedData = receivedData.toJSONString() {
            #if DEBUG
                Log.normal(message: "Network Response \(receivedData)")
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
                throw StashError.network(.responseInvalid).loggedError()
            }

        default:
            if let type = errorType, let answer = try? JSONDecoder().decode(type, from: receivedData) {
                throw StashAPIError<S>(error: answer)
            }

            throw StashError.network(.responseInvalid).loggedError()
        }
    }
}
