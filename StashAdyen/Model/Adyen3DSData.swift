//
//  Adyen3DSData.swift
//  StashAdyen
//
//  Created by Borna Beakovic on 19/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct Adyen3DS2Data: Codable {
    let token: String?
    let paymentMethodType: String?
    let type: String?
    let paymentData: String?
    let paReq: String?
    let md: String?
    let url: String?
}
