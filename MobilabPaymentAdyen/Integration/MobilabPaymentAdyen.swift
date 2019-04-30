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
                                             idempotencyKey: idempotencyKey,
                                             completion: completion)
            } else if let sepaData = try getSEPAData(from: registrationRequest) {
                self.handleSEPARequest(sepaData: sepaData,
                                       pspData: pspData,
                                       controller: controller,
                                       idempotencyKey: idempotencyKey,
                                       completion: completion)
            } else {
                completion(.failure(MobilabPaymentError.configuration(.pspInvalidConfiguration)))
            }
        } catch let error as MobilabPaymentError {
            completion(.failure(error))
        } catch {
            completion(.failure(MobilabPaymentError.other(GenericErrorDetails.from(error: error))))
        }
    }

    public func provideAliasCreationDetail(for _: RegistrationData,
                                           idempotencyKey: String,
                                           completion: @escaping (Swift.Result<AliasCreationDetail?, MobilabPaymentError>) -> Void) {
        #warning("Update this return URL")
        guard let returnUrl = URL(string: "app://mobilabpayment")
        else { completion(.failure(MobilabPaymentError.configuration(.invalidReturnURL))); return }

        let controller = AdyenPaymentControllerWrapper(providerIdentifier: self.pspIdentifier.rawValue) { token in
            let creationDetail: AdyenAliasCreationDetail? = AdyenAliasCreationDetail(token: token, returnUrl: returnUrl)
            completion(.success(creationDetail))
        }

        controller.start()
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
        self.pspIdentifier = .adyen
    }

    private func handleCreditCardRequest(creditCardData: CreditCardAdyenData,
                                         pspData: AdyenData,
                                         controller: AdyenPaymentControllerWrapper,
                                         idempotencyKey: String,
                                         completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        let billingData = creditCardData.billingData
        let creditCardPreparator = CreditCardPreparator(billingData: billingData, creditCardData: creditCardData)
        controller.continueRegistration(sessionId: pspData.sessionID,
                                        billingData: billingData,
                                        paymentMethodPreparator: creditCardPreparator) { result in
            switch result {
            case let .success(token):
                completion(.success(token))
            case let .failure(error):
                let mlError = error as? MobilabPaymentError ?? MobilabPaymentError.other(GenericErrorDetails.from(error: error))
                completion(.failure(mlError))
            }
            self.controllerForIdempotencyKey[idempotencyKey] = nil
        }
    }

    private func handleSEPARequest(sepaData: SEPAAdyenData, pspData: AdyenData,
                                   controller: AdyenPaymentControllerWrapper,
                                   idempotencyKey: String,
                                   completion: @escaping PaymentServiceProvider.RegistrationResultCompletion) {
        let billingData = sepaData.billingData
        let sepaPreparator = SEPAPreparator(billingData: billingData, sepaData: sepaData)
        controller.continueRegistration(sessionId: pspData.sessionID,
                                        billingData: billingData,
                                        paymentMethodPreparator: sepaPreparator) { result in
            switch result {
            case let .success(token):
                completion(.success(token))
            case let .failure(error):
                let mlError = error as? MobilabPaymentError ?? MobilabPaymentError.other(GenericErrorDetails.from(error: error))
                completion(.failure(mlError))
            }
            self.controllerForIdempotencyKey[idempotencyKey] = nil
        }
    }

    private func getPaymentController(for idempotencyKey: String) throws -> AdyenPaymentControllerWrapper {
        guard let controller = self.controllerForIdempotencyKey[idempotencyKey]
        else { throw MobilabPaymentError.other(GenericErrorDetails(description: "Internal Error: Missing Adyen Payment Controller")) }

        return controller
    }

    private func getCreditCardData(from registrationRequest: RegistrationRequest) throws -> CreditCardAdyenData? {
        guard let cardData = registrationRequest.registrationData as? CreditCardData else { return nil }

        guard let holderName = cardData.holderName else { throw MobilabPaymentError.validation(.creditCardMissingHolderName) }

        let creditCardRequest = CreditCardAdyenData(number: cardData.cardNumber,
                                                    expiryMonth: String(cardData.expiryMonth),
                                                    expiryYear: String(cardData.expiryYear),
                                                    cvc: cardData.cvv,
                                                    holderName: holderName,
                                                    billingData: cardData.billingData)
        return creditCardRequest
    }

    private func getSEPAData(from registrationRequest: RegistrationRequest) throws -> SEPAAdyenData? {
        guard let data = registrationRequest.registrationData as? SEPAData
        else { return nil }

        guard let ownerName = data.billingData.name?.fullName
        else { throw MobilabPaymentError.validation(.billingMissingName) }

        return SEPAAdyenData(ownerName: ownerName, ibanNumber: data.iban, billingData: data.billingData)
    }

    private func isSepaRequest(registrationRequest: RegistrationRequest) -> Bool {
        return registrationRequest.registrationData is SEPAData
    }
}
