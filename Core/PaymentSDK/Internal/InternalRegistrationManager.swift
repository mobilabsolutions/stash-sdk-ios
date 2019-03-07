//
//  InternalRegistrationManager.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class InternalRegistrationManager {
    var networkingClient: NetworkClientCore!
    var provider: PaymentServiceProvider!

    init(provider: PaymentServiceProvider, client: NetworkClientCore) {
        self.provider = provider
        self.networkingClient = client
    }

    func addMethod(paymentMethod: MLPaymentMethod, completion: @escaping RegistrationResult) {
        
        self.networkingClient.createAlias { result in

            switch result {
            case .success(let response):
                
                let standardizedData = StandardizedData(aliasId: response.aliasId)
                let registrationRequest = RegistrationRequest(standardizedData: standardizedData,
                                                             pspData: response.psp.toData(),
                                                             registrationData: paymentMethod.methodData.toBSPayoneData())
                
                self.provider.handleRegistrationRequest(registrationRequest: registrationRequest, completion: { resultRegistration in
                    
                    switch resultRegistration {
                    case .success(let pspAlias):
                        

                        let cardExtra = paymentMethod.toAliasExtra()
                        
                        let updateAliasRequest = UpdateAliasRequest(aliasId: response.aliasId, pspAlias: pspAlias, extra: cardExtra!)
                        self.networkingClient.updateAlias(request: updateAliasRequest, completion: { updateResult in
                            switch resultRegistration {
                            case .success(_):
                                completion(.success(pspAlias))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        })
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
