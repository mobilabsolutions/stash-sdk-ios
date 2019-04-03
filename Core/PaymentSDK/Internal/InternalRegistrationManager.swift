//
//  InternalRegistrationManager.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

class InternalRegistrationManager {
    private let networkingClient = InternalPaymentSDK.sharedInstance.networkingClient

    func addMethod(paymentMethod: PaymentMethod, completion: @escaping RegistrationResultCompletion, presentingViewController: UIViewController? = nil) {
        guard let cardExtra = paymentMethod.toAliasExtra()
        else {
            completion(.failure(MobilabPaymentError.cardExtraNotExtractable))
            return
        }

        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: paymentMethod.type)

        let createAliasRequest = CreateAliasRequest(pspType: provider.pspIdentifier.rawValue)
        self.networkingClient.createAlias(request: createAliasRequest) { result in
            switch result {
            case let .success(response):
                self.performRegistration(with: response, for: paymentMethod, paymentMethodExtra: cardExtra, viewController: presentingViewController, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func performRegistration(with alias: AliasResponse, for paymentMethod: PaymentMethod,
                                     paymentMethodExtra: AliasExtra, viewController: UIViewController?, completion: @escaping RegistrationResultCompletion) {
        let registrationRequest = RegistrationRequest(aliasId: alias.aliasId,
                                                      pspData: alias.psp,
                                                      registrationData: paymentMethod.methodData,
                                                      viewController: viewController)

        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: paymentMethod.type)
        provider.handleRegistrationRequest(registrationRequest: registrationRequest, completion: { resultRegistration in
            switch resultRegistration {
            case let .success(pspAlias):
                let updateAliasRequest = UpdateAliasRequest(aliasId: alias.aliasId, pspAlias: pspAlias, extra: paymentMethodExtra)
                self.networkingClient.updateAlias(request: updateAliasRequest, completion: { _ in
                    switch resultRegistration {
                    case .success:
                        completion(.success(alias.aliasId))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                })

            case let .failure(error):
                completion(.failure(error))
            }
        })
    }
}
