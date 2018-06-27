//
//  RequestHeader.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension RouterRequest {
    func getContentTypeHeader() -> String {
        switch self {
        case .addCreditCard(_),
             .addSEPA(_),
             .updatePanAlias(_):
            return "application/json"
        case .bsRegisterCreditCard(_,_),
             .bsFetchMethodAlias(_,_):
            return "application/soap+xml"
        case .hcRegisterCreditCard(_,_):
            return "text/xml"
        }
    }
}
