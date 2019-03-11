//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

public struct SEPAData: Codable {
    public let bankNumber: String
    public let IBAN: String

    public init(bankNumber: String, IBAN: String) {
        self.bankNumber = bankNumber
        self.IBAN = IBAN
    }
}

extension SEPAData: BaseMethodData {
    func toBSPayoneData() -> Data? {
        return nil
    }
}
