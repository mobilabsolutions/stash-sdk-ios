//
//  MLBillingData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLBillingData: Codable {
    
    var email = ""
    var firstName: String?
    var lastName: String?
    var address1: String?
    var address2: String?
    var ZIP: String?
    var city: String?
    var state: String?
    var country: String?
    var phone: String?
    var languageId: String?
    
    init(email: String) {
        self.email = email
    }
    
    init(email: String, firstName: String, lastName: String, address1: String, address2: String,
         ZIP: String, city: String, state: String, country: String, phone: String, languageId: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.ZIP = ZIP
        self.city = city
        self.state = state
        self.country = country
        self.phone = phone
        self.languageId = languageId
    }
}
