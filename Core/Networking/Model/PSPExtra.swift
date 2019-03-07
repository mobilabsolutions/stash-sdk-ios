//
//  PSPExtra.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 05/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct PSPExtra: Codable {
    
    public var apiVersion: String
    public var encoding: String
    public var hash: String
    public var merchantId: String
    public var portalId: String
    public var accountId: String
    public var request: String
    public var responseType: String?
    public var type: String
    public var mode: String
    
    public static func from(data: Data?) -> PSPExtra? {
        
        if let _data = data, let decoded = try? JSONDecoder().decode(PSPExtra.self, from: _data) {
            return decoded
        }
        return nil
    }
}
