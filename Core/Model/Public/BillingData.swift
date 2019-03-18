//
//  MLBillingData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

/// The data identifying the billing data. Different payment service providers require different data to be present
/// for payment method registration to succeed.
public struct BillingData {
    /// The email address associated with the billing data
    let email: String?
    /// The name of the person to bill
    let name: String?
    /// First (real-world) address part
    let address1: String?
    /// Second (real-world) address part
    let address2: String?
    /// The zip code associated with the billing data
    let zip: String?
    /// The city name associated with the billing data
    let city: String?
    /// The state asscociated with the billing data
    let state: String?
    /// The country associated with the billing data
    let country: String?
    /// The phone number associated with the billing data
    let phone: String?
    /// The id of the language to use (e.g. deu)
    let languageId: String?

    /// Initialize the billing data with select properties
    public init(email: String? = nil,
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
