//
//  Codable+Extras.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 06/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toData() -> Data? {
    
        let encodedObject = try? JSONEncoder().encode(self)
        return encodedObject
    }
    
    func toURLQueryItem(name:String) -> URLQueryItem? {
        if let _self = self as? String {
            return URLQueryItem(name: name, value: _self)
        }
        return nil
    }
}
