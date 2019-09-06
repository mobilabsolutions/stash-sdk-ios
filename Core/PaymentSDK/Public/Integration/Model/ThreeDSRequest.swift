//
//  3DS2Request.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 12/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A struct that includes 3DS authentication information obtained from the Stash backend
/// This data is sent to be handled by PSP module
/// - Used solely during module development
public struct ThreeDSRequest: Encodable {
    // Adyen authentication token
    public let token: String?
    // Adyen payment method type
    public let paymentMethodType: String?
    // Adyen type (scheme)
    public let type: String?
    // Adyen payment data
    public let paymentData: String?
    // Adyen paReq for 3DS1
    public let paReq: String?
    // Adyen md for 3DS1
    public let md: String?
    // Adyen url to redirect user for 3DS1 validation
    public let url: String?

    init(aliasResponse: AliasResponse) {
        self.token = aliasResponse.token
        self.paymentMethodType = aliasResponse.paymentMethodType
        self.type = aliasResponse.actionType
        self.paymentData = aliasResponse.paymentData
        self.paReq = aliasResponse.paReq
        self.md = aliasResponse.md
        self.url = aliasResponse.url
    }
}
