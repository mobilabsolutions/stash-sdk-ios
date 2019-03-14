//
//  InternalRegistrationManager.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class InternalRegistrationManager {
    private let networkingClient = InternalPaymentSDK.sharedInstance.networkingClient
    private let provider = InternalPaymentSDK.sharedInstance.provider

    func addMethod(paymentMethod: PaymentMethod, completion: @escaping RegistrationResultCompletion) {
        guard let cardExtra = paymentMethod.toAliasExtra()
        else {
            completion(.failure(MLError(title: "Card extra not extractable",
                                        description: "Internal SDK error: Could not read alias extra from payment method", code: 102)))
            return
        }

        self.networkingClient.createAlias { result in
            switch result {
            case let .success(response):
                let registrationRequest = RegistrationRequest(aliasId: response.aliasId,
                                                              pspData: response.psp,
                                                              registrationData: paymentMethod.methodData)

                self.provider.handleRegistrationRequest(registrationRequest: registrationRequest, completion: { resultRegistration in

                    switch resultRegistration {
                    case let .success(pspAlias):
                        let updateAliasRequest = UpdateAliasRequest(aliasId: response.aliasId, pspAlias: pspAlias, extra: cardExtra)
                        self.networkingClient.updateAlias(request: updateAliasRequest, completion: { _ in
                            switch resultRegistration {
                            case .success:
                                completion(.success(response.aliasId))
                            case let .failure(error):
                                completion(.failure(error))
                            }
                        })

                    case let .failure(error):
                        completion(.failure(error))
                    }
                })

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
