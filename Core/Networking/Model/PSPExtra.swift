//
//  PSPExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PSPExtra: Codable {
    public let apiVersion: String
    public let encoding: String
    public let hash: String
    public let merchantId: String
    public let portalId: String
    public let accountId: String
    public let request: String
    public let responseType: String?
    public let type: String
    public let mode: String

    public static func from(data: Data?) -> PSPExtra? {
        guard let data = data, let decoded = try? JSONDecoder().decode(PSPExtra.self, from: data)
        else { return nil }

        return decoded
    }
}
