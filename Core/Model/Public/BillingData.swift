//
//  MLBillingData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

@objc(MLBillingData) public class BillingData: NSObject {
    let email: String?
    let name: String?
    let address1: String?
    let address2: String?
    let zip: String?
    let city: String?
    let state: String?
    let country: String?
    let phone: String?
    let languageId: String?

    @objc public init(email: String? = nil,
                      name: String? = nil,
                      address1: String? = nil,
                      address2: String? = nil,
                      zip: String? = nil,
                      city: String? = nil,
                      state: String? = nil,
                      country: String? = nil,
                      phone: String? = nil,
                      languageId: String? = nil) {
        self.name = name
        self.email = email
        self.address1 = address1
        self.address2 = address2
        self.zip = zip
        self.city = city
        self.state = state
        self.country = country
        self.phone = phone
        self.languageId = languageId
    }
}
