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
        case .createAlias(_),
             .updateAlias(_),
             .addCreditCard(_),
             .addSEPA(_):
            return "application/json"
        case .bsRegisterCreditCard(_,_):
            return "application/soap+xml"
        }
    }
}
