//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

public class MobilabPaymentBSPayone : PaymentServiceProvider {
    
    var networkingClient: NetworkClientBSPayone?
    
    public func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping (NetworkClientResult<String, MLError>) -> Void) {
        
        networkingClient?.registerCreditCard(paymentMethod: "", success: { (success) in
            
        }, failiure: { (error) in
            
        })
        
        completion(.success("TestALias"))
    }
    
    public init() {
        networkingClient = NetworkClientBSPayone()
    }
}
