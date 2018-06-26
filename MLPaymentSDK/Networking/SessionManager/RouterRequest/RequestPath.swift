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
            
        case .addCreditCardBS(_), .addCreditCardHC(_):
            return "register/creditcard"
        case .addSEPABS(_), .addSEPAHC(_):
            return "register/sepa"
        case .updatePanAlias(_):
            return "update/panalias"
            
        case .bsRegisterCreditCard(_,_),
             .bsFetchMethodAlias(_,_),
             .hcRegisterCreditCard(_,_):
            return ""
            
        }
    }
}
