//
//  VersionService.swift
//  StashDemo
//
//  Created by Borna Beakovic on 27/08/2019.
//  Copyright © 2019 Robert Rabe. All rights reserved.
//

import Foundation

class InfoService {
    public static func getBackendURL() -> String {
        guard let backendURL = Bundle.main.infoDictionary?["StashBackendURL"] as? String else {
            fatalError("StashBackendURL value is missing from Info.plist")
        }
        return backendURL
    }

    public static func getMerchantURL() -> String {
        guard let backendURL = Bundle.main.infoDictionary?["StashMerchantURL"] as? String else {
            fatalError("StashMerchantURL value is missing from Info.plist")
        }
        return backendURL
    }

    public static func getDemoAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    public static func getSDKVersion() -> String {
        return Bundle(identifier: "com.mobilabsolutions.stash.core")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    public static func getBackendVersion() -> String {
        guard let version = getBackendURL().components(separatedBy: "/").last else {
            fatalError("Invalid StashBackendURL in Info.plist")
        }
        return version
    }
}
