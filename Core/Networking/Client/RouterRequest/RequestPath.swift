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
        case .createAlias(_):
            return "v2/alias"
        case .updateAlias(let id, _):
            return "v2/alias/" + id
        case .addCreditCard(_):
            return "register/creditcard"
        case .addSEPA(_):
            return "register/sepa"
            
        case .bsRegisterCreditCard(_,_):
            return ""
            
        }
    }
}
