//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public enum NetworkClientError: Error {
    case shouldTryDecodingErrorResponse
}

public protocol NetworkClient {
    typealias Completion<T> = ((Result<T, MobilabPaymentError>) -> Void)
    func fetch<T: Decodable, S: Decodable & MobilabPaymentErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>)
}

public extension NetworkClient {
    func fetch<T: Decodable, S: Decodable & MobilabPaymentErrorConvertible>(with request: RouterRequestProtocol, responseType: T.Type, errorType: S.Type?, completion: @escaping Completion<T>) {
        let urlRequest = request.asURLRequest()

        if let method = urlRequest.httpMethod, let url = urlRequest.url {
            Log.normal(message: "MobilabPayment request: \(method) \(url)")
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
            } catch let errorType as MobilabPaymentApiError<S> {
                completion(.failure(errorType.toMobilabPaymentError()))
            } catch let error as MobilabPaymentError {
                completion(.failure(error))
            } catch {
                completion(.failure(MobilabPaymentError.other(GenericErrorDetails.from(error: error))))
            }
        }
        dataTask.resume()
    }

    private func handleResponse<T: Decodable, S: MobilabPaymentErrorConvertible & Decodable>(data: Data?, response: URLResponse?, error: Error?,
                                                                                             decodingType: T.Type, errorType: S.Type?) throws -> T {
        if let error = error as NSError? {
            throw MobilabPaymentError.network(.requestFailed(code: error.code, description: error.localizedDescription)).loggedError()
        }

        guard let httpResponse = response as? HTTPURLResponse, let receivedData = data else {
            throw MobilabPaymentError.network(.responseInvalid).loggedError()
        }

        if let receivedData = receivedData.toJSONString() {
            #if DEBUG
                Log.normal(message: receivedData)
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
                throw MobilabPaymentError.network(.responseInvalid).loggedError()
            }

        default:
            if let type = errorType, let answer = try? JSONDecoder().decode(type, from: receivedData) {
                throw MobilabPaymentApiError<S>(error: answer)
            }

            throw MobilabPaymentError.network(.responseInvalid).loggedError()
        }
    }
}
