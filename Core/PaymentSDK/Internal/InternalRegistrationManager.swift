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
    
    func addMethod(paymentMethod: MLPaymentMethod, completion: (NetworkClientResult<Bool, MLError>) -> Void) {
        
        let requestObject = CreateAliasRequest(pspIdentifier: "", mask: "")
        networkingClient.createAlias(request: requestObject) {
            
            let standardizedData = StandardizedData(aliasId: "")
            let additionalRegistrationData = AdditionalRegistrationData(data: [:])
            
            let registrationReques = RegistrationRequest(standardizedData: standardizedData, additionalRegistrationData: additionalRegistrationData)
            self.provider.handleRegistrationRequest(registrationRequest: registrationReques, completion: { (providerResult) in
                
                let updateAliasRequest = UpdateAliasRequest(aliasId: "aliasId", billingData: "data")
                self.networkingClient.updateAlias(request: updateAliasRequest, completion: {
                    
                })
                
            })
        }
    }
    
}
