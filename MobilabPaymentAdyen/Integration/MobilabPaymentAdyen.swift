//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import MobilabPaymentUI
import UIKit

public class MobilabPaymentAdyen: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientAdyen?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        guard let pspData = registrationRequest.pspData.adyen else {
            completion(.failure(MLError(title: "Missing configuration data", description: "Provided configuration data is wrong", code: 4)))
            return
        }

        do {
            if let creditCardRequest = try getCreditCardData(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest, pspData: pspData, completion: completion)
            } else if self.isSepaRequest(registrationRequest: registrationRequest) {
                completion(.success(nil))
            } else {
                #warning("Update codes here when errors are finalized")
                completion(.failure(MLError(title: "PSP Error", description: "Unknown payment method parameters", code: 0)))
            }
        } catch AdyenIntegrationError.missingHolderName {
            completion(.failure(MLError(title: "Unsupported Credit Card Type", description: "The provided credit card type is not supported", code: 1)))
        } catch {
            completion(.failure(MLError(title: "Unknown error occurred", description: "An unknown error occurred while handling payment method registration in BS module", code: 3)))
        }
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

//    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
//        return [.sepa, .creditCard]
//    }
//
//    public func viewController(for methodType: PaymentMethodType,
//                               billingData: BillingData?,
//                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
//        switch methodType {
//        case .creditCard:
//            return CustomBackButtonContainerViewController(viewController: CreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
//                                                           configuration: configuration)
//        case .sepa:
//            return CustomBackButtonContainerViewController(viewController: SEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
//                                                           configuration: configuration)
//        case .payPal:
//            return nil
//        }
//    }

    public init() {
        self.networkingClient = NetworkClientAdyen()
        self.pspIdentifier = .adyen
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardAdyenData, pspData: AdyenExtra,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardAdyenData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData
        else { return nil }

        guard let creditCardHolderName = cardData.billingData.name
        else { throw AdyenIntegrationError.missingHolderName }

        let bsCreditCardRequest = CreditCardAdyenData(number: cardData.cardNumber,
                                                      expiryMonth: String(cardData.expiryMonth),
                                                      expiryYear: String(cardData.expiryYear),
                                                      cvc: cardData.cvv,
                                                      holderName: creditCardHolderName)
        return bsCreditCardRequest
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }

    private enum AdyenIntegrationError: Error {
        case missingHolderName
    }
}
