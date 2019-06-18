//
//  PaymentMethodManager.swift
//  Demo
//
//  Created by Rupali Ghate on 16.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentAdyen
import MobilabPaymentBraintree
import MobilabPaymentCore

import Foundation

class PaymentService {
    // MARK: Properties

    static let shared = PaymentService()

    private var sdkIsSetUp = false
    private let testModeEnabled = true

    private var user = User()

    private let baseUrl: String = "https://payment-dev.mblb.net/merchant"
    private let paymentMethodBaseUrl: String
    private let authorizationUrl: String
    private let userControllerUrl: String

    // MARK: Initializer

    private init() {
        self.paymentMethodBaseUrl = self.baseUrl + "/payment-method"
        self.authorizationUrl = self.baseUrl + "/authorization"
        self.userControllerUrl = self.baseUrl + "/user"
    }

    // MARK: Public methods

    func getOrCreateUser(completion: @escaping (Result<User, Error>) -> Void) {
        var user = User()
        if !user.userId.isEmpty {
            user.save(userId: user.userId)
            completion(.success(user))
            return
        }

        guard let url = URL(string: userControllerUrl) else {
            completion(.failure(CustomError(description: "Invalid URL")))
            return
        }
        self.makeRequest(url: url, httpMethod: .POST) { result in
            switch result {
            case let .failure(err):
                completion(.failure(err))
            case let .success(data):
                do {
                    if let responseObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String], let userId = responseObj["userId"] {
                        user.save(userId: userId)
                        completion(.success(user))
                    }
                } catch let err {
                    completion(.failure(err))
                }
            }
        }
    }

    func addNewPaymentMethod(viewController: UIViewController, completion: @escaping RegistrationResultCompletion) {
        let paymentManager = PaymentService.shared
        paymentManager.configureSDK()

        let configuration = PaymentMethodUIConfiguration()

        MobilabPaymentSDK.configureUI(configuration: configuration)
        MobilabPaymentSDK.getRegistrationManager().registerPaymentMethodUsingUI(on: viewController, completion: completion)
    }

    func createPaymentMethod(for user: User, paymentMethod: PaymentMethod, completion: @escaping (Result<String, Error>) -> Void) {
        guard !user.userId.isEmpty else { return }

        guard let url = URL(string: paymentMethodBaseUrl) else {
            completion(.failure(CustomError(description: "Invalid URL")))
            return
        }

        var params: [String: Any] = [
            "aliasId": paymentMethod.alias,
            "type": paymentMethod.type.paymentMethodIdentifier,
            "userId": user.userId,
        ]

        var paymentTypeExtraData = [String: Any]()
        switch paymentMethod.extraAliasInfo {
        case let .creditCard(details):
            paymentTypeExtraData["ccExpiryMonth"] = details.expiryMonth
            paymentTypeExtraData["ccExpiryYear"] = details.expiryYear
            paymentTypeExtraData["ccMask"] = details.creditCardMask
            paymentTypeExtraData["ccType"] = details.creditCardType.rawValue
            params["ccData"] = paymentTypeExtraData

        case let .sepa(details):
            paymentTypeExtraData["iban"] = details.maskedIban
            params["sepaData"] = paymentTypeExtraData

        case let .payPal(details):
            paymentTypeExtraData["email"] = details.email
            params["payPalData"] = paymentTypeExtraData
        }

        self.makeRequest(url: url, params: params, httpMethod: .POST) { result in
            switch result {
            case let .failure(err):
                completion(.failure(err))
            case let .success(data):
                do {
                    if let responseObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String], let paymentMethodId = responseObj["paymentMethodId"] {
                        completion(.success(paymentMethodId))
                    } else {
                        completion(.failure(CustomError(description: "Failed to add payment method")))
                    }
                } catch let err {
                    completion(.failure(err))
                }
            }
        }
    }

    func getPaymentMethods(for userId: String, completion: @escaping (Result<[MerchantPaymentMethod], Error>) -> Void) {
        guard !userId.isEmpty, let url = URL(string: "\(paymentMethodBaseUrl)/\(userId)") else {
            completion(.failure(CustomError(description: "Invalid URL")))
            return
        }

        self.makeRequest(url: url, httpMethod: .GET) { result in
            switch result {
            case let .failure(err):
                completion(.failure(err))
            case let .success(data):
                do {
                    var merchantPaymentMethods = [MerchantPaymentMethod]()
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                        let arr = json["paymentMethods"] as? [[String: Any]] {
                        for dict in arr {
                            if let paymentMethod = MerchantPaymentMethod(with: dict) {
                                merchantPaymentMethods.append(paymentMethod)
                            }
                        }
                    }
                    completion(.success(merchantPaymentMethods))
                } catch let err {
                    completion(.failure(err))
                }
            }
        }
    }

    func deletePaymentMethod(for paymentMethodId: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "\(paymentMethodBaseUrl)/\(paymentMethodId)") else {
            completion(CustomError(description: "Invalid URL"))
            return
        }
        self.makeRequest(url: url, httpMethod: .DELETE) { result in
            switch result {
            case .success:
                completion(nil)
            case let .failure(err):
                completion(err)
            }
        }
    }

    func makePayment(forPaymentMethodId paymentMethodId: String, amount: NSDecimalNumber, currency: String, description: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: authorizationUrl) else {
            completion(CustomError(description: "Invalid URL"))
            return
        }

        let header: [String: String] = [
            "Idempotent-Key": UUID().uuidString, // Any unique string with length between 10 - 40 char long
        ]

        let params: [String: Any] = [
            "amount": amount,
            "currency": currency,
            "paymentMethodId": paymentMethodId,
            "reason": description,
        ]

        makeRequest(url: url, header: header, params: params, httpMethod: .PUT) { result in
            switch result {
            case let .failure(err):
                completion(err)
            case .success:
                completion(nil)
            }
        }
    }

    // MARK: Helpers

    private func configureSDK() {
        guard !self.sdkIsSetUp
        else { return }

        let adyen = MobilabPaymentAdyen()
        let adyenIntegration = PaymentProviderIntegration(paymentServiceProvider: adyen)

        let braintree = MobilabPaymentBraintree(urlScheme: "com.mobilabsolutions.payment.Demo.paypal")
        guard let braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree, paymentMethodTypes: [.payPal])
        else { fatalError("Braintree should support PayPal payment method but does not!") }

        let configuration = MobilabPaymentConfiguration(publicKey: "mobilab-D4eWavRIslrUCQnnH6cn",
                                                        endpoint: "https://payment-dev.mblb.net/api/v1",
                                                        integrations: [adyenIntegration, braintreeIntegration])
        configuration.loggingEnabled = true
        configuration.useTestMode = self.testModeEnabled

        MobilabPaymentSDK.initialize(configuration: configuration)

        self.sdkIsSetUp = true
    }

    private func makeRequest(url: URL, header: [String: String]? = nil, params: [String: Any]? = nil, httpMethod: HTTPMethod, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let header = header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let params = params {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                return
            }
            request.httpBody = httpBody
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10

        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { data, response, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(CustomError(description: "Invalid response")))
                return
            }

            switch httpResponse.statusCode {
            case 200, 201, 204:
                completion(.success(data))
            default:
                completion(.failure(CustomError(description: "Unknown Error with status code \(httpResponse.statusCode)")))
            }
        }.resume()
    }

    private func getAlias(for paymentMethod: PaymentMethod) -> String? {
        var alias: String?
        switch paymentMethod.extraAliasInfo {
        case let .creditCard(details):
            alias = details.creditCardMask
        case let .sepa(details):
            alias = details.maskedIban
        case let .payPal(details):
            alias = details.email
        }
        return alias
    }
}
