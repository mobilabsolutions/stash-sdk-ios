//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A structure that holds WeChatSDK redirect data.
public struct WeChatRedirectData {
    let appIdentifier: String
    let partnerIdentifier: String
    let prepayIdentifier: String
    let timestamp: UInt32
    let package: String
    let nonce: String
    let signature: String

    // Initializer that receives redirect data dictionary
    public init(dictionary: [String: String]?) {
        self.appIdentifier = dictionary?["appid"] ?? ""
        self.partnerIdentifier = dictionary?["partnerid"] ?? ""
        self.prepayIdentifier = dictionary?["prepayid"] ?? ""
        self.timestamp = UInt32(dictionary?["timestamp"] ?? "") ?? 0
        self.package = dictionary?["package"] ?? ""
        self.nonce = dictionary?["noncestr"] ?? ""
        self.signature = dictionary?["sign"] ?? ""
    }
}
