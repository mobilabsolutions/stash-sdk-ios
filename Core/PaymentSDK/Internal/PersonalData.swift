//
//  PersonalData.swift
//  MobilabPaymentCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct PersonalData: Codable {
    let city: String?
    let country: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let street: String?
    let zip: String?

    init(billingData: BillingData) {
        self.city = billingData.city
        self.country = billingData.country
        self.email = billingData.email
        self.firstName = billingData.name?.firstName
        self.lastName = billingData.name?.lastName
        self.street = billingData.address1
        self.zip = billingData.zip
    }
}
