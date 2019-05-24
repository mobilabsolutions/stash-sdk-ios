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
@objc(MLBillingData) public class BillingData: NSObject {
    /// The email address associated with the billing data
    @objc public let email: String?
    /// The name of the person to bill
    @objc public let name: NameProviding?
    /// First (real-world) address part
    @objc public let address1: String?
    /// Second (real-world) address part
    @objc public let address2: String?
    /// The zip code associated with the billing data
    @objc public let zip: String?
    /// The city name associated with the billing data
    @objc public let city: String?
    /// The state asscociated with the billing data
    @objc public let state: String?
    /// The country associated with the billing data
    @objc public let country: String?
    /// The phone number associated with the billing data
    @objc public let phone: String?
    /// The id of the language to use (e.g. deu)
    @objc public let languageId: String?

    /// Initialize the billing data with select properties
    @objc public init(email: String? = nil,
                      name: NameProviding? = nil,
                      address1: String? = nil,
                      address2: String? = nil,
                      zip: String? = nil,
                      city: String? = nil,
                      state: String? = nil,
                      country: String? = nil,
                      phone: String? = nil,
                      languageId: String? = nil,
                      basedOn billingData: BillingData? = nil) {
        self.name = name ?? billingData?.name
        self.email = email ?? billingData?.email
        self.address1 = address1 ?? billingData?.address1
        self.address2 = address2 ?? billingData?.address2
        self.zip = zip ?? billingData?.zip
        self.city = city ?? billingData?.city
        self.state = state ?? billingData?.state
        self.country = country ?? billingData?.country
        self.phone = phone ?? billingData?.phone
        self.languageId = languageId ?? billingData?.languageId
    }
}
