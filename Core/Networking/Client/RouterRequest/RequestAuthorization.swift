//
//  RequestAuthorization.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension RouterRequest {
    func getAuthorizationHeader() -> String {
        switch self {
        case .createAlias(_),
             .updateAlias(_),
             .addCreditCard(_),
             .addSEPA(_):
            let token = MLConfigurationBuilder.sharedInstance.configuration?.publicToken
            return "Bearer \(token!.toBase64())"
        case .bsRegisterCreditCard(_, let creditCardResponse):
            let data = "\(creditCardResponse.username):\(creditCardResponse.password)".data(using: getEncoding())
            if let encodedData = data?.base64EncodedString() {
                return "Basic \(encodedData)"
            }
            return ""
        }
    }
    
    func getEncoding() -> String.Encoding {
        return String.Encoding.utf8
    }
}
