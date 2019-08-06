//
//  SDKResetter.swift
//  StashTests
//
//  Created by Robert on 24.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import StashCore
import XCTest

@objc class SDKResetter: NSObject {
    @objc class func resetStash() {
        InternalPaymentSDK.sharedInstance.pspCoordinator.removeAllProviders()
        InternalPaymentSDK.sharedInstance.resetInitialization()
    }
}
