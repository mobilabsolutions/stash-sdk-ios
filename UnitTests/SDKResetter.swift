//
//  SDKResetter.swift
//  MobilabPaymentTests
//
//  Created by Robert on 24.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

@objc class SDKResetter: NSObject {
    @objc class func resetMobilabSDK() {
        InternalPaymentSDK.sharedInstance.pspCoordinator.removeAllProviders()
        InternalPaymentSDK.sharedInstance.resetInitialization()
    }
}
