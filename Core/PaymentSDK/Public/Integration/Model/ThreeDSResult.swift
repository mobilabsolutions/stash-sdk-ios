//
//  ThreeDSResponse.swift
//  StashCore
//
//  Created by Borna Beakovic on 29/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A struct that includes 3DS authentication information obtained from PSP module
/// - Used solely during module development
public struct ThreeDSResult: Encodable {
    // Data received from device fingerprinting
    public let fingerprintResult: String?
    // Data received from challenge result
    public let challengeResult: String?
    // PaRes data received from 3DS1 authentication
    public let paRes: String?
    // Md data received from 3DS1 authentication
    public let md: String?

    public init(fingerprintResult: String) {
        self.fingerprintResult = fingerprintResult
        self.challengeResult = nil
        self.paRes = nil
        self.md = nil
    }

    public init(challengeResult: String) {
        self.fingerprintResult = nil
        self.challengeResult = challengeResult
        self.paRes = nil
        self.md = nil
    }

    public init(paRes: String, md: String) {
        self.fingerprintResult = nil
        self.challengeResult = nil
        self.paRes = paRes
        self.md = md
    }
}
