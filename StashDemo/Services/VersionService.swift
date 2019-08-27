//
//  VersionService.swift
//  StashDemo
//
//  Created by Borna Beakovic on 27/08/2019.
//  Copyright © 2019 Robert Rabe. All rights reserved.
//

import Foundation

class VersionService {
    public static func getDemoAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    public static func getSDKVersion() -> String {
        return Bundle(identifier: "com.mobilabsolutions.stash.core")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    public static func getBackendVersion() -> String {
        return "v1"
    }
}
