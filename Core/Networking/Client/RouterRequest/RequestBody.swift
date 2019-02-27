//
//  RequestBody.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension RouterRequest {
    func getHttpBody() -> Data? {
        switch self {
        case .createAlias(let data):
            return try? JSONEncoder().encode(data)
            
        case .updateAlias(_, let data):
            return try? JSONEncoder().encode(data)
            
        case .addSEPA(let data):
            return try? JSONEncoder().encode(data)
            
        case .addCreditCard(let data):
            return try? JSONEncoder().encode(data)
            
        case .bsRegisterCreditCard(let method,let creditCard):
            guard let xmlStr = creditCard.serializeXML(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
    
        }
    }
}
