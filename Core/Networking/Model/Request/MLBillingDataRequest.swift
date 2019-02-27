//
//  MLBillingDataRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLBillingDataReqest: Codable {
    
    private(set) var email = ""
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var address1: String?
    private(set) var address2: String?
    private(set) var ZIP: String?
    private(set) var city: String?
    private(set) var state: String?
    private(set) var country: String?
    private(set) var phone: String?
    private(set) var languageId: String?
    
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
        self.phone = billingData.phone
        self.languageId = billingData.languageId
    }
}

