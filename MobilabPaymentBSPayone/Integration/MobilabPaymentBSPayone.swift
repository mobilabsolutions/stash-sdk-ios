//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

public class MobilabPaymentBSPayone: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          idempotencyKey _: String,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: BSPayoneData.self)
            let billingData = getBillingData(from: registrationRequest) ?? BillingData()

            if let creditCardRequest = try getCreditCardData(from: registrationRequest),
                let creditCardData = registrationRequest.registrationData as? CreditCardData,
                let creditCardExtra = creditCardData.toCreditCardExtra() {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest,
                                             pspData: pspData,
                                             creditCardExtra: creditCardExtra,
                                             billingData: billingData,
                                             completion: completion)
            } else if let _ = try getSepaData(from: registrationRequest),
                let sepaData = registrationRequest.registrationData as? SEPAData {
                let registration = PSPRegistration(pspAlias: nil, aliasExtra: AliasExtra(sepaConfig: sepaData.toSEPAExtra(), billingData: billingData))
                completion(.success(registration))
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
        return [.creditCard, .sepa]
    }

    public func viewController(for methodType: PaymentMethodType,
                               billingData: BillingData?,
                               configuration: PaymentMethodUIConfiguration) -> (UIViewController & PaymentMethodDataProvider)? {
        switch methodType {
        case .creditCard:
            return CustomBackButtonContainerViewController(viewController: BSCreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .sepa:
            return CustomBackButtonContainerViewController(viewController: BSSEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .payPal:
            return nil
        }
    }

    public init() {
        self.networkingClient = NetworkClientBSPayone()
        self.pspIdentifier = .bsPayone
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardBSPayoneData,
                                         pspData: BSPayoneData,
                                         creditCardExtra: CreditCardExtra,
                                         billingData: BillingData,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspData: pspData, completion: { result in
            switch result {
            case let .success(value):
                let registration = PSPRegistration(pspAlias: value, aliasExtra: AliasExtra(ccConfig: creditCardExtra, billingData: billingData))
                completion(.success(registration))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardBSPayoneData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData
        else { return nil }

        guard let cardType = cardData.cardType.bsCardTypeIdentifier
        else { throw MobilabPaymentError.validation(.cardTypeNotSupported) }

        let bsCreditCardRequest = CreditCardBSPayoneData(cardPan: cardData.cardNumber,
                                                         cardType: cardType,
                                                         cardExpireDate: String(format: "%02d%02d", cardData.expiryYear, cardData.expiryMonth),
                                                         cardCVC2: cardData.cvv, billingData: cardData.billingData)

        return bsCreditCardRequest
    }

    private func getSepaData(from registrationRequest: RegistrationRequest) throws -> SEPABSPayoneData? {
        guard let data = registrationRequest.registrationData as? SEPAData
        else { return nil }

        return SEPABSPayoneData(iban: data.iban)
    }

    private func getBillingData(from registrationRequest: RegistrationRequest) -> BillingData? {
        if let data = registrationRequest.registrationData as? SEPAData {
            return data.billingData
        } else if let data = registrationRequest.registrationData as? CreditCardData {
            return data.billingData
        }

        return nil
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }
}
