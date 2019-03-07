//
//  Data+Extras.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 25/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension Data {

    func fromISOLatinToUTF8() -> Data? {
        if let xmlStringLatinEncoded = String(data: self, encoding: String.Encoding.isoLatin1) {
            return xmlStringLatinEncoded.data(using: String.Encoding.utf8)
        }
        return nil
    }
    
    func toJSONString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
