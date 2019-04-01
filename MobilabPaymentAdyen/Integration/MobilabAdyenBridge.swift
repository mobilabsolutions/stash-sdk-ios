//
//  MobilabBSPayoneBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

@objc(MLMobilabAdyen) public class MobilabAdyenBridge: NSObject {
    @objc public static func createModule() -> Any {
        return MobilabPaymentAdyen()
    }
}
