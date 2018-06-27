//
//  RequestBody.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

extension RouterRequest {
    func getHttpBody() -> Data? {
        switch self {
        case .addCreditCard(let data):
            let json = Mapper().toJSONString(data, prettyPrint: true)
            return json?.data(using: getEncoding())
            
        case .addSEPA(let data):
            let json = Mapper().toJSONString(data, prettyPrint: true)
            print(json!)
            return json?.data(using: getEncoding())
            
        case .updatePanAlias(let data):
            let json = Mapper().toJSONString(data, prettyPrint: true)
            return json?.data(using: getEncoding())
            
        case .bsRegisterCreditCard(let method,let creditCard):
            guard let xmlStr = creditCard.serializeXML(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
            
        case .bsFetchMethodAlias(let method, let creditCard):
            guard let xmlStr = creditCard.serializeXMLForAlias(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
            
        case .hcRegisterCreditCard(let method, let creditCard):
            guard let xmlStr = creditCard.serializeXML(paymentMethod: method) else { return nil }
            return xmlStr.data(using: getEncoding())
        }
    }
}
