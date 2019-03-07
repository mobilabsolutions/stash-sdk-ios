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

    func addMethod(paymentMethod: MLPaymentMethod, completion: @escaping (NetworkClientResult<Bool, MLError>) -> Void) {
        
        self.networkingClient.createAlias { result in

            switch result {
            case .success(var response):
                
                // Currently response is missing some psp params so we add them manually here
                response.psp.apiVersion = "3.11"
                response.psp.merchantId = "42865"
                response.psp.portalId = "2030968"
                response.psp.request = "creditcardcheck"
                response.psp.responseType = "JSON"
                
                let standardizedData = StandardizedData(aliasId: response.aliasId)
                let registrationRequest = RegistrationRequest(standardizedData: standardizedData,
                                                             pspData: response.psp.toData(),
                                                             registrationData: paymentMethod.methodData.toBSPayoneData())
                
                self.provider.handleRegistrationRequest(registrationRequest: registrationRequest, completion: { _ in
                    
                    //                let updateAliasRequest = UpdateAliasRequest(aliasId: "aliasId", billingData: "data")
                    //                self.networkingClient.updateAlias(request: updateAliasRequest, completion: {
                    //
                    //                })
                    
                })
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
