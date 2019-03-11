//
//  InternalRegistrationManager.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class InternalRegistrationManager {
    private let networkingClient: NetworkClientCore
    private let provider: PaymentServiceProvider

    init(provider: PaymentServiceProvider, client: NetworkClientCore) {
        self.provider = provider
        self.networkingClient = client
    }

    func addMethod(paymentMethod: MLPaymentMethod, completion: @escaping RegistrationResult) {
        self.networkingClient.createAlias { result in

            switch result {
            case let .success(response):

                let standardizedData = StandardizedData(aliasId: response.aliasId)
                let registrationRequest = RegistrationRequest(standardizedData: standardizedData,
                                                              pspData: response.psp.toData(),
                                                              registrationData: paymentMethod.methodData.toBSPayoneData())

                self.provider.handleRegistrationRequest(registrationRequest: registrationRequest, completion: { resultRegistration in

                    switch resultRegistration {
                    case let .success(pspAlias):

                        let cardExtra = paymentMethod.toAliasExtra()

                        let updateAliasRequest = UpdateAliasRequest(aliasId: response.aliasId, pspAlias: pspAlias, extra: cardExtra!)
                        self.networkingClient.updateAlias(request: updateAliasRequest, completion: { _ in
                            switch resultRegistration {
                            case .success:
                                completion(.success(pspAlias))
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
