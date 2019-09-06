//
//  VerifyAliasRequest.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 12/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct VerifyAliasRequest: Codable {
    let aliasId: String
    let idempotencyKey: String
    let challengeResult: String?
    let fingerprintResult: String?
    let md: String?
    let paRes: String?

    init(aliasId: String, idempotencyKey: String, threeDSResult: ThreeDSResult) {
        self.aliasId = aliasId
        self.idempotencyKey = idempotencyKey
        self.challengeResult = threeDSResult.challengeResult
        self.fingerprintResult = threeDSResult.fingerprintResult
        self.md = threeDSResult.md
        self.paRes = threeDSResult.paRes
    }
}
