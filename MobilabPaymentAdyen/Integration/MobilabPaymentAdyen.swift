//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Adyen
import AdyenCard
import AdyenSEPA
import MobilabPaymentCore
import UIKit

public class MobilabPaymentAdyen: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientAdyen

    private var controllerForIdempotencyKey: [String: AdyenPaymentControllerWrapper] = [:]

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: AdyenData.self)
            let controller = try getPaymentController(for: idempotencyKey)

            if let creditCardData = try getCreditCardData(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardData: creditCardData,
                                             pspData: pspData,
                                             controller: controller,
                                             completion: completion)
            } else if let sepaData = try getSEPAData(from: registrationRequest) {
                self.handleSEPARequest(sepaData: sepaData,
                                       pspData: pspData,
                                       controller: controller,
                                       completion: completion)
            } else {
                #warning("Update codes here when errors are finalized")
                completion(.failure(MLError(title: "PSP Error", description: "Unknown payment method parameters", code: 0)))
            }
        } catch PaymentServiceProviderError.missingOrInvalidConfigurationData {
            completion(.failure(MLError(title: "Missing configuration data", description: "Provided configuration data is wrong", code: 1)))
        } catch AdyenIntegrationError.missingHolderName {
            completion(.failure(MLError(title: "Unsupported Credit Card Type", description: "The provided credit card type is not supported", code: 1)))
        } catch {
            completion(.failure(MLError(title: "Unknown error occurred", description: "An unknown error occurred while handling payment method registration in BS module", code: 3)))
        }
    }

    public func provideAliasCreationDetail(for _: RegistrationData,
                                           idempotencyKey: String,
                                           completion: @escaping (MobilabPaymentCore.Result<AliasCreationDetail?, MLError>) -> Void) {
        #warning("Update this return URL")
        guard let returnUrl = URL(string: "app://mobilabpayment")
        else { completion(.failure(MLError(description: "App return URL not valid", code: 1234))); return }

        let controller = AdyenPaymentControllerWrapper { token in
            let creationDetail: AdyenAliasCreationDetail? = AdyenAliasCreationDetail(token: token, returnUrl: returnUrl)
            completion(.success(creationDetail))
        }

        self.controllerForIdempotencyKey[idempotencyKey] = controller
    }

    public var supportedPaymentMethodTypes: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    public var supportedPaymentMethodTypeUserInterfaces: [PaymentMethodType] {
        return [.sepa, .creditCard]
    }

    public func viewController(for methodType: PaymentMethodType,
                               billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        switch methodType {
        case .creditCard:
            return CustomBackButtonContainerViewController(viewController: AdyenCreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .sepa:
            return CustomBackButtonContainerViewController(viewController: AdyenSEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .payPal:
            return nil
        }
    }

    public init() {
        self.networkingClient = NetworkClientAdyen()
        self.pspIdentifier = .adyen
    }

    private func handleCreditCardRequest(creditCardData: CreditCardAdyenData, pspData: AdyenData,
                                         controller _: AdyenPaymentControllerWrapper,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient.registerCreditCard(creditCardData: creditCardData, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func handleSEPARequest(sepaData: SEPAAdyenData, pspData: AdyenData,
                                   controller _: AdyenPaymentControllerWrapper,
                                   completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient.registerSEPA(sepaData: sepaData, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getPaymentController(for idempotencyKey: String) throws -> AdyenPaymentControllerWrapper {
        guard let controller = self.controllerForIdempotencyKey[idempotencyKey]
        else { throw AdyenIntegrationError.missingPaymentController }

        return controller
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardAdyenData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData else { return nil }

        guard let holderName = cardData.holderName else { throw AdyenIntegrationError.missingHolderName }

        let creditCardRequest = CreditCardAdyenData(number: cardData.cardNumber,
                                                    expiryMonth: String(cardData.expiryMonth),
                                                    expiryYear: String(cardData.expiryYear),
                                                    cvc: cardData.cvv,
                                                    holderName: holderName)
        return creditCardRequest
    }

    private func getSEPAData(from registrationRequest: RegistrationRequest) throws -> SEPAAdyenData? {
        guard let data = registrationRequest.registrationData as? SEPAData
        else { return nil }

        guard let ownerName = data.billingData.name
        else { throw AdyenIntegrationError.missingHolderName }

        return SEPAAdyenData(ownerName: ownerName, ibanNumber: data.iban)
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }

    private enum AdyenIntegrationError: Error {
        case missingOrInvalidConfigurationData
        case missingHolderName
        case missingPaymentController
    }
}
