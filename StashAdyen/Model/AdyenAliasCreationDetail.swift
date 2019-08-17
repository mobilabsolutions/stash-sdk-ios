//
//  AdyenAliasCreationDetail.swift
//  StashAdyen
//
//  Created by Robert on 15.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

class AdyenAliasCreationDetail: AliasCreationDetail {
    let token: String
    let returnUrl: String
    let channel: String = "ios"

    init(token: String, returnUrl: String) {
        self.token = token
        self.returnUrl = returnUrl
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decode(String.self, forKey: .token)
        self.returnUrl = try container.decode(String.self, forKey: .returnUrl)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.returnUrl, forKey: .returnUrl)
        try container.encode(self.channel, forKey: .channel)
    }

    private enum CodingKeys: CodingKey {
        case token
        case returnUrl
        case channel
    }
}
