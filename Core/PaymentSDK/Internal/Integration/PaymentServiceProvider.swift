//
//  PSPIntegrationProtocol.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation


public protocol PaymentServiceProvider {
    
    var pspType:String { get set }
    var publicKey:String { get set }
    
    func handleRegistrationRequest(registrationRequest:RegistrationRequest, completion: @escaping (NetworkClientResult<String, MLError>) -> Void)
}
