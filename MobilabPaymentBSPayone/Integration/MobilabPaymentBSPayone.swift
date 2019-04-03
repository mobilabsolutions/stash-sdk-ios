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

public class MobilabPaymentBSPayone: PaymentServiceProvider {
    public let pspIdentifier: MobilabPaymentProvider

    let networkingClient: NetworkClientBSPayone?

    public func handleRegistrationRequest(registrationRequest: RegistrationRequest,
                                          completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        do {
            let pspData = try registrationRequest.pspData.toPSPData(type: BSPayoneData.self)

            if let creditCardRequest = try getCreditCardDate(from: registrationRequest) {
                self.handleCreditCardRequest(creditCardRequest: creditCardRequest, pspData: pspData, completion: completion)
            } else if self.isSepaRequest(registrationRequest: registrationRequest) {
                completion(.success(nil))
            } else {
                completion(.failure(MobilabPaymentError.pspUnknownPaymentMethodData))
            }
        } catch let error as MobilabPaymentError {
            completion(.failure(error))
        } catch {
            completion(.failure(MobilabPaymentError.pspUnknownError(pspIdentifier)))
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
            return CustomBackButtonContainerViewController(viewController: CreditCardInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .sepa:
            return CustomBackButtonContainerViewController(viewController: SEPAInputCollectionViewController(billingData: billingData, configuration: configuration),
                                                           configuration: configuration)
        case .payPal:
            return nil
        }
    }

    public init() {
        self.networkingClient = NetworkClientBSPayone()
        self.pspIdentifier = .bsPayone
    }

    private func handleCreditCardRequest(creditCardRequest: CreditCardBSPayoneData, pspData: BSPayoneData,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        self.networkingClient?.registerCreditCard(creditCardData: creditCardRequest, pspData: pspData, completion: { result in
            switch result {
            case let .success(value): completion(.success(.some(value)))
            case let .failure(error): completion(.failure(error))
            }
        })
    }

    private func getCreditCardDate(from registrationRequest: RegistrationRequest) throws -> CreditCardBSPayoneData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData
        else { return nil }

        guard let cardType = cardData.cardType.bsCardTypeIdentifier
        else { throw MobilabPaymentError.pspCreditCardTypeNotSupported }

        let bsCreditCardRequest = CreditCardBSPayoneData(cardPan: cardData.cardNumber,
                                                         cardType: cardType,
                                                         cardExpireDate: String(format: "%02d%02d", cardData.expiryYear, cardData.expiryMonth),
                                                         cardCVC2: cardData.cvv)

        return bsCreditCardRequest
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }
}
