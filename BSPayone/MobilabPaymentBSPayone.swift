//
//  MobilabPaymentBSPayone.swift
//  BSPayone
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

class MobilabPaymentBSPayone : PaymentServiceProvider {
    
    func handleRegistrationRequest(registrationRequest: RegistrationRequest, completion: @escaping (MLResult<String, MLError>) -> Void) {
        completion(.success("TestALias"))
    }
    
}
