//
//  PaymentMethodManager.swift
//  Demo
//
//  Created by Rupali Ghate on 16.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import StashAdyen
import StashBraintree
import StashCore

import Foundation
import UIKit

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

    /// Due to lack of login screen, at present, application is creating only one user ID. Every time application is reinstalled, a new user ID will be requested from merchant backend.
    /// Once user is created and user ID string is received successfully using merchant-backend API, it is stored in UserDefaults.
    /// This method checks if the user ID is aready available in UserDefaults.
    /// If yes, returns the user ID from UserDefaults. If not, invokes merchant backend API to create new user
    ///
    /// - Returns: Result object with User object in case of successful user ID retrieval or Error.

    func getOrCreateUser(completion: @escaping (Result<User, Error>) -> Void) {
        let user = User()
        if !user.userId.isEmpty {
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

    /// Configures PaymentSDK and invokes paymentSDK method to register a new payment-method using SDK UI screen.
    func initiateSDKPaymentMethodRegistrationWithUI(on viewController: UIViewController, completion: @escaping RegistrationResultCompletion) {
        let paymentManager = PaymentService.shared
        paymentManager.configureSDK()

        let configuration = PaymentMethodUIConfiguration()

        Stash.configureUI(configuration: configuration)
        // display paymentSDK register screens on current viewController
        Stash.getRegistrationManager().registerPaymentMethodUsingUI(on: viewController, completion: completion)
    }

    /// Calls merchant-backend API to create a new payment method for specified user-id
    /// - Parameters:
    ///     - user: user object for userId
    ///     - paymentMethod: A PaymentMethod object for providing alias, type of payment method and extra details associated with payment method.
    ///                        e.g. email address for paypal, masked IBan for SPPA, etc
    ///
    /// - Returns: Result<String, Error>: with paymentMethodId string in case of successful response, Error in case of failure.
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

    /// Calls merchant-backend API to get list of payment methods for the specified userId.
    /// - Parameters:
    ///     - userId: userId String
    /// - Returns: Result<[MerchantPaymentMethod], Error>: with an array of MerchantPaymentMethod case of successful response, Error in case of failure.
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

    /// Calls merchant-backend API to delete payment methods using specified paymentMethodId.
    /// - Parameters:
    ///     - paymentMethodId
    /// - Returns: nil for successful deletion, Error in case of failure.
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

    /// Calls merchant-backend authorization API to make payment.
    /// - Parameters:
    ///     - paymentMethodId: This was received from merchant backend in getPaymentMethods() call
    ///     - amount: in cents
    ///     - currency: currency code for device Locale. e.g. EUR for euros
    ///     - description
    /// - Returns: nil for successful authorization (payment), Error in case of failure.
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

    /// Method to configure PaymentSDK. currently using Adyen PSP.
    private func configureSDK() {
        guard !self.sdkIsSetUp
        else { return }

        let adyen = StashAdyen()
        guard let adyenIntegration = PaymentProviderIntegration(paymentServiceProvider: adyen, paymentMethodTypes: [.sepa])
        else { fatalError("Adyen should support SEPA payment method but does not!") }

        let braintree = StashBraintree(urlScheme: "com.mobilabsolutions.stash.Demo.paypal")
        guard let braintreeIntegration = PaymentProviderIntegration(paymentServiceProvider: braintree, paymentMethodTypes: [.payPal, .creditCard])
        else { fatalError("Braintree should support PayPal payment method but does not!") }

        let configuration = StashConfiguration(publishableKey: "mobilabios-3FkSmKQ0sUmzDqxciqRF",
                                               endpoint: "https://payment-dev.mblb.net/api/v1",
                                               integrations: [adyenIntegration, braintreeIntegration])
        configuration.loggingEnabled = true
        configuration.useTestMode = self.testModeEnabled

        Stash.initialize(configuration: configuration)

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
}
