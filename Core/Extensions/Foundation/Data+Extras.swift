//
//  Data+Extras.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 25/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension Data {
    func toXMLDictionary(parsingKeys: [String]) -> [String: String]? {
        let parser = XMLParser(data: self)
        let deleg = MLXMLParser(parsingKeys: parsingKeys)
        parser.delegate = deleg

        if parser.parse() {
            return deleg.results
        }
        return nil
    }

    func fromISOLatinToUTF8() -> Data? {
        if let xmlStringLatinEncoded = String(data: self, encoding: String.Encoding.isoLatin1) {
            return xmlStringLatinEncoded.data(using: String.Encoding.utf8)
        }
        return nil
    }
}
