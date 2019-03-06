//
//  MLXMLParser.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 25/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLXMLParser: NSObject {
    var parsingKeys: [String]

    init(parsingKeys: [String]) {
        self.parsingKeys = parsingKeys
    }

    public var results: [String: String] = [String: String]()
    var currentValue: String?
}

extension MLXMLParser: XMLParserDelegate {
    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes _: [String: String] = [:]) {
        if self.parsingKeys.contains(elementName) {
            self.currentValue = String()
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        self.currentValue? += string
    }

    func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        if self.parsingKeys.contains(elementName) {
            self.results[elementName] = self.currentValue ?? ""
            self.currentValue = nil
        }
    }

    func parser(_: XMLParser, parseErrorOccurred _: Error) {
        self.currentValue = nil
    }
}
