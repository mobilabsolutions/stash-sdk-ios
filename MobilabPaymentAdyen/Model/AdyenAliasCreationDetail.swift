//
//  AdyenAliasCreationDetail.swift
//  MobilabPaymentAdyen
//
//  Created by Robert on 15.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

class AdyenAliasCreationDetail: AliasCreationDetail {
    let token: String
    let returnUrl: URL

    init(token: String, returnUrl: URL) {
        self.token = token
        self.returnUrl = returnUrl
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decode(String.self, forKey: .token)
        self.returnUrl = try container.decode(URL.self, forKey: .returnUrl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
        try container.encode(returnUrl, forKey: .returnUrl)
    }

    private enum CodingKeys: CodingKey {
        case token
        case returnUrl
    }
}
