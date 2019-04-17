//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

public class MobilabPaymentAdyen: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientAdyen

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: AdyenData.self)

            if let creditCardData = try getCreditCardData(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardData: creditCardData, pspData: pspData, completion: completion)
            } else if let sepaData = try getSEPAData(from: registrationRequest) {
                self.handleSEPARequest(sepaData: sepaData, pspData: pspData, completion: completion)
            } else {
                completion(.failure(MobilabPaymentError.configuration(.pspInvalidConfiguration)))
            }
        } catch let error as MobilabPaymentError {
            completion(.failure(error))
        } catch {
            completion(.failure(MobilabPaymentError.other(GenericErrorDetails.from(error: error))))
        }
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
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient.registerCreditCard(creditCardData: creditCardData, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func handleSEPARequest(sepaData: SEPAAdyenData, pspData: AdyenData,
                                   completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient.registerSEPA(sepaData: sepaData, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardAdyenData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData else { return nil }

        guard let holderName = cardData.holderName else { throw MobilabPaymentError.validation(.creditCardMissingHolderName) }

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
        else { throw MobilabPaymentError.validation(.billingMissingName) }

        return SEPAAdyenData(ownerName: ownerName, ibanNumber: data.iban)
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }
}
