//
//  MLAddCreditCardResponse.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//
import Foundation

class MLAddCreditCardResponse: Codable {
    
    private(set) var paymentAlias = ""
    private(set) var url = ""
    private(set) var merchantId = ""
    private(set) var action = ""
    private(set) var panAlias = ""
    private(set) var username = ""
    private(set) var password = ""
    private(set) var eventExtId = ""
    private(set) var currency = ""
    private(set) var amount = 0
    private(set) var kind = "creditcard"
    private(set) var customerId = ""
    private(set) var timestamp = Date()
    private(set) var type = ""
    
    func serializeXML(paymentMethod: MLPaymentMethod) -> String? {
        print("Should be overriden!")
        return nil
    }
}
