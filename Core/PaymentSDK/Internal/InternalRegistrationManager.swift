//
//  InternalRegistrationManager.swift
//  StashCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

class InternalRegistrationManager {
    func addMethod(paymentMethod: PaymentMethod,
                   idempotencyKey: String?,
                   completion: @escaping RegistrationResultCompletion,
                   presentingViewController: UIViewController? = nil) {
        let internalWrapper = InternalRegistrationManagerWrapper(paymentMethod: paymentMethod, idempotencyKey: idempotencyKey,
                                                                 resultCompletion: completion, presentingViewController: presentingViewController)
        internalWrapper.initiate()
    }
}

class InternalRegistrationManagerWrapper {
    private let networkingClient = InternalPaymentSDK.sharedInstance.networkingClient
    private let paymentMethod: PaymentMethod
    private let idempotencyKey: String?
    private let presentingViewController: UIViewController?
    private let uniqueRegistrationIdentifier = UUID().uuidString
    private var provider: PaymentServiceProvider {
        return InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: self.paymentMethod.type)
    }

    private var pspRegistrationResult: PSPRegistration?
    private var resultCompletion: RegistrationResultCompletion

    init(paymentMethod: PaymentMethod, idempotencyKey: String?, resultCompletion: @escaping RegistrationResultCompletion, presentingViewController: UIViewController? = nil) {
        self.paymentMethod = paymentMethod
        self.idempotencyKey = idempotencyKey
        self.resultCompletion = resultCompletion
        self.presentingViewController = presentingViewController
    }

    func initiate() {
        Log.event(description: "function initiated")

        self.provider.provideAliasCreationDetail(for: self.paymentMethod.methodData, idempotencyKey: self.idempotencyKey, uniqueRegistrationIdentifier: self.uniqueRegistrationIdentifier) { creationDetailResult in
            switch creationDetailResult {
            case let .success(detail):

                let createAliasRequest = CreateAliasRequest(pspType: self.provider.pspIdentifier.rawValue,
                                                            aliasDetail: detail,
                                                            idempotencyKey: self.idempotencyKey ?? self.uniqueRegistrationIdentifier)
                self.networkingClient.createAlias(request: createAliasRequest) { result in
                    switch result {
                    case let .success(response):
                        self.performRegistration(with: response)
                    case let .failure(error):
                        self.resultCompletion(.failure(error))
                    }
                }
            case let .failure(error):
                self.resultCompletion(.failure(error))
            }
        }
    }

    private func performRegistration(with alias: CreateAliasResponse) {
        let registrationRequest = RegistrationRequest(aliasId: alias.aliasId,
                                                      pspData: alias.psp,
                                                      registrationData: self.paymentMethod.methodData,
                                                      viewController: self.presentingViewController)

        Log.event(description: "function initiated")

        let provider = InternalPaymentSDK.sharedInstance.pspCoordinator.getProvider(forPaymentMethodType: self.paymentMethod.type)
        provider.handleRegistrationRequest(registrationRequest: registrationRequest,
                                           idempotencyKey: self.idempotencyKey,
                                           uniqueRegistrationIdentifier: self.uniqueRegistrationIdentifier,
                                           completion: { resultRegistration in
                                               switch resultRegistration {
                                               case let .success(pspResult):
                                                   self.pspRegistrationResult = pspResult
                                                   self.updateAlias(with: alias.aliasId)
                                               case let .failure(error):
                                                   self.resultCompletion(.failure(error))
                                               }
        })
    }

    private func updateAlias(with aliasId: String) {
        guard let pspResult = pspRegistrationResult else {
            fatalError("Psp registration result should be available at this point")
        }
        let updateAliasRequest = UpdateAliasRequest(aliasId: aliasId,
                                                    pspAlias: pspResult.pspAlias,
                                                    extra: pspResult.aliasExtra,
                                                    idempotencyKey: self.idempotencyKey ?? self.uniqueRegistrationIdentifier)

        Log.event(description: "function initiated")

        self.networkingClient.updateAlias(request: updateAliasRequest, completion: { updateResponse in
            switch updateResponse {
            case let .success(updateResult):
                if updateResult.resultCode == nil {
                    // SEPA response is empty
                    self.handleAuthorizedResultCode(aliasId: aliasId)
                } else {
                    if updateResult.resultCode == .authorised {
                        self.handleAuthorizedResultCode(aliasId: aliasId)
                    } else {
                        self.provider.handle3DS(request: ThreeDSRequest(aliasResponse: updateResult), viewController: self.presentingViewController!, completion: { handleUpdateAliasResponse in
                            switch handleUpdateAliasResponse {
                            case let .success(result):
                                let verifyAliasRequest = VerifyAliasRequest(aliasId: aliasId,
                                                                            idempotencyKey: self.idempotencyKey ?? self.uniqueRegistrationIdentifier,
                                                                            threeDSResult: result)
                                self.verifyAlias(with: verifyAliasRequest)
                            case let .failure(error):
                                self.resultCompletion(.failure(error))
                            }
                        })
                    }
                }
            case let .failure(error):
                self.resultCompletion(.failure(error))
            }
        })
    }

    private func verifyAlias(with request: VerifyAliasRequest) {
        Log.event(description: "function initiated")

        self.networkingClient.verifyAlias(request: request, completion: { updateResponse in
            switch updateResponse {
            case let .success(updateResult):
                if updateResult.resultCode == .authorised {
                    self.handleAuthorizedResultCode(aliasId: request.aliasId)
                } else {
                    self.provider.handle3DS(request: ThreeDSRequest(aliasResponse: updateResult), viewController: self.presentingViewController!, completion: { handleVerifyAliasResponse in
                        switch handleVerifyAliasResponse {
                        case let .success(result):
                            let verifyAliasRequest = VerifyAliasRequest(aliasId: request.aliasId,
                                                                        idempotencyKey: self.idempotencyKey ?? self.uniqueRegistrationIdentifier,
                                                                        threeDSResult: result)
                            self.verifyAlias(with: verifyAliasRequest)
                        case let .failure(error):
                            self.resultCompletion(.failure(error))
                        }
                    })
                }
            case let .failure(error):
                self.resultCompletion(.failure(error))
            }
        })
    }

    private func handleAuthorizedResultCode(aliasId: String) {
        guard let publicPaymentMethodType = self.paymentMethod.type.publicPaymentMethodType
        else { fatalError("SDK error: For every internal payment method type that is used, there should be a corresponding public type") }
        guard let pspResult = pspRegistrationResult else {
            fatalError("Psp registration result should be available at this point")
        }
        let registration = PaymentMethodAlias(alias: aliasId,
                                              paymentMethodType: publicPaymentMethodType,
                                              extraAliasInfo: pspResult.overwritingExtraAliasInfo
                                                  ?? self.paymentMethod.methodData.extraAliasInfo)
        self.resultCompletion(.success(registration))
    }
}
