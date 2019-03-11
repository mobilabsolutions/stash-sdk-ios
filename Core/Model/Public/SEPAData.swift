//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct SEPAData: Codable {
    let bankNumber: String
    let IBAN: String
}

extension SEPAData: BaseMethodData {
    func toBSPayoneData() -> Data? {
        return nil
    }
}
