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
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if parsingKeys.contains(elementName) {
            currentValue = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if parsingKeys.contains(elementName) {
            results[elementName] = currentValue ?? ""
            currentValue = nil
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        currentValue = nil
    }
    
}
