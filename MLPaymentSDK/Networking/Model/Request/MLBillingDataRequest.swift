//
//  MLBillingDataRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLBillingDataReqest: Mappable {
    
    private(set) var email = ""
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var address1: String?
    private(set) var address2: String?
    private(set) var ZIP: String?
    private(set) var city: String?
    private(set) var state: String?
    private(set) var country: String?
    
    init() { }
    
    init(billingData: MLBillingData) {
        self.email = billingData.email
        self.firstName = billingData.firstName
        self.lastName = billingData.lastName
        self.address1 = billingData.address1
        self.address2 = billingData.address2
        self.ZIP = billingData.ZIP
        self.city = billingData.city
        self.state = billingData.state
        self.country = billingData.country
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        address1 <- map["address1"]
        address2 <- map["address2"]
        ZIP <- map["ZIP"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
    }
}

