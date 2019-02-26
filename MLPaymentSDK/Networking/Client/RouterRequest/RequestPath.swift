//
//  RequestPath.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension RouterRequest {
    func getRelativePath() -> String? {
        
        switch self {
            
        case .addCreditCard(_):
            return "register/creditcard"
        case .addSEPA(_):
            return "register/sepa"
            
        case .bsRegisterCreditCard(_,_):
            return ""
            
        }
    }
}
