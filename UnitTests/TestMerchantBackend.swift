//
//  TestMerchantBackend.swift
//  MobilabPaymentCore
//
//  Created by Robert on 16.07.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

class TestMerchantBackend {
    private let endpoint: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let userId: String

    init(endpoint: String = "https://payment-dev.mblb.net/merchant", userId: String = "9os4fezF3QuS8EoV") {
        self.endpoint = endpoint
        self.userId = userId
    }

    private enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }

    private struct CustomError: Error, CustomStringConvertible {
        let description: String
    }

    func createPaymentMethod(alias: String, paymentMethodType: String, completion: @escaping (Result<TestMerchantPaymentMethod, Error>) -> Void) {
        guard let url = URL(string: self.endpoint)?.appendingPathComponent("payment-method")
        else { completion(.failure(CustomError(description: "Could not create the endpoint URL"))); return }

        let request = CreatePaymentMethodRequest(aliasId: alias, type: paymentMethodType, userId: userId)

        guard let encoded = try? self.encoder.encode(request)
        else { completion(.failure(CustomError(description: "Could not serialize the request"))); return }

        self.makeRequest(url: url, body: encoded, httpMethod: .POST, completion: completion)
    }

    func authorizePayment(payment: PaymentRequest, completion: @escaping (Result<TestMerchantAuthorization, Error>) -> Void) {
        guard let url = URL(string: self.endpoint)?.appendingPathComponent("authorization")
        else { completion(.failure(CustomError(description: "Could not create the endpoint URL"))); return }

        guard let encoded = try? self.encoder.encode(payment)
        else { completion(.failure(CustomError(description: "Could not serialize the request"))); return }

        self.makeRequest(url: url, body: encoded, httpMethod: .PUT, completion: completion)
    }

    private func makeRequest<T: Codable>(url: URL, body: Data? = nil, httpMethod: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = body
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10

        print("Making Request to \(request.url?.absoluteString ?? "nil")")
        print("Data: \(body.flatMap { String(data: $0, encoding: .utf8) } ?? "nil")")

        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { data, response, err in
            if let err = err {
                completion(.failure(err))
                return
            }

            print("Response: \(data.flatMap { String(data: $0, encoding: .utf8) } ?? "nil")")

            guard let httpResponse = response as? HTTPURLResponse,
                let data = data,
                let deserialized = try? self.decoder.decode(T.self, from: data) else {
                completion(.failure(CustomError(description: "Invalid response")))
                return
            }

            if 200..<300 ~= httpResponse.statusCode {
                completion(.success(deserialized))
            } else {
                completion(.failure(CustomError(description: "Unknown Error with status code \(httpResponse.statusCode)")))
            }
        }.resume()
    }
}

private struct CreatePaymentMethodRequest: Codable {
    let aliasId: String
    let type: String
    let userId: String
}

private struct CreateUserReqeust: Codable {}

private struct User: Codable {
    let userId: String
}

struct TestMerchantPaymentMethod: Codable {
    let paymentMethodId: String
}

struct TestMerchantAuthorization: Codable {
    let additionalInfo: String?
    let amount: Int?
    let currency: String?
    let status: String
    let transactionId: String?
}

struct PaymentRequest: Codable {
    let amount: Int
    let currency: String
    let paymentMethodId: String
    let reason: String
}
