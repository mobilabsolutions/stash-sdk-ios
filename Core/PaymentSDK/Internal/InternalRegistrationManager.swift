//
//  InternalRegistrationManager.swift
//  StashCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class InternalRegistrationManager {
    private let networkingClient = InternalPaymentSDK.sharedInstance.networkingClient

    func addMethod(paymentMethod: PaymentMethod, idempotencyKey: String?,
                   completion: @escaping RegistrationResultCompletion,
                   presentingViewController: UIViewController? = nil) {
        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: paymentMethod.type)
        let uniqueRegistrationIdentifier = UUID().uuidString

        provider.provideAliasCreationDetail(for: paymentMethod.methodData, idempotencyKey: idempotencyKey, uniqueRegistrationIdentifier: uniqueRegistrationIdentifier) { creationDetailResult in
            switch creationDetailResult {
            case let .success(detail):
                self.createAlias(provider: provider,
                                 paymentMethod: paymentMethod,
                                 aliasCreationDetail: detail,
                                 idempotencyKey: idempotencyKey,
                                 uniqueRegistrationIdentifier: uniqueRegistrationIdentifier,
                                 completion: completion,
                                 presentingViewController: presentingViewController)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func createAlias(provider: PaymentServiceProvider,
                             paymentMethod: PaymentMethod,
                             aliasCreationDetail: AliasCreationDetail?,
                             idempotencyKey: String?,
                             uniqueRegistrationIdentifier: String,
                             completion: @escaping RegistrationResultCompletion,
                             presentingViewController: UIViewController?) {
        let createAliasRequest = CreateAliasRequest(pspType: provider.pspIdentifier.rawValue,
                                                    aliasDetail: aliasCreationDetail,
                                                    idempotencyKey: idempotencyKey ?? uniqueRegistrationIdentifier)

        self.networkingClient.createAlias(request: createAliasRequest) { result in
            switch result {
            case let .success(response):
                self.performRegistration(with: response,
                                         for: paymentMethod,
                                         viewController: presentingViewController,
                                         idempotencyKey: idempotencyKey,
                                         uniqueRegistrationIdentifier: uniqueRegistrationIdentifier,
                                         completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func performRegistration(with alias: AliasResponse,
                                     for paymentMethod: PaymentMethod,
                                     viewController: UIViewController?,
                                     idempotencyKey: String?,
                                     uniqueRegistrationIdentifier: String,
                                     completion: @escaping RegistrationResultCompletion) {
        let registrationRequest = RegistrationRequest(aliasId: alias.aliasId,
                                                      pspData: alias.psp,
                                                      registrationData: paymentMethod.methodData,
                                                      viewController: viewController)

        guard let publicPaymentMethodType = paymentMethod.type.publicPaymentMethodType
        else { fatalError("SDK error: For every internal payment method type that is used, there should be a corresponding public type") }

        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: paymentMethod.type)
        provider.handleRegistrationRequest(registrationRequest: registrationRequest,
                                           idempotencyKey: idempotencyKey, uniqueRegistrationIdentifier: uniqueRegistrationIdentifier, completion: { resultRegistration in
                                               switch resultRegistration {
                                               case let .success(pspResult):
                                                   let updateAliasRequest = UpdateAliasRequest(aliasId: alias.aliasId,
                                                                                               pspAlias: pspResult.pspAlias,
                                                                                               extra: pspResult.aliasExtra,
                                                                                               idempotencyKey: idempotencyKey ?? uniqueRegistrationIdentifier)

                                                   self.networkingClient.updateAlias(request: updateAliasRequest, completion: { updateResult in
                                                       switch updateResult {
                                                       case .success:
                                                           let registration = PaymentMethodAlias(alias: alias.aliasId,
                                                                                                 paymentMethodType: publicPaymentMethodType,
                                                                                                 extraAliasInfo: pspResult.overwritingExtraAliasInfo
                                                                                                     ?? paymentMethod.methodData.extraAliasInfo)
                                                           completion(.success(registration))
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
