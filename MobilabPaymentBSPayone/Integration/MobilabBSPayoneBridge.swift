//
//  MobilabBSPayoneBridge.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

@objc(MLMobilabBSPayone) public class MobilabBSPayoneBridge: NSObject {
    @objc public static func createModule() -> Any {
        return MobilabPaymentBSPayone()
    }
}
