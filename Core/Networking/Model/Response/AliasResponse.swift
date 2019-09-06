//
//  AliasResponse.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 12/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public struct AliasResponse: Decodable {
    public let resultCode: AliasResultCode?
    public let token: String?
    public let paymentData: String?
    public let paymentMethodType: String?
    public let actionType: String?
    public let paReq: String?
    public let md: String?
    public let url: String?
}
