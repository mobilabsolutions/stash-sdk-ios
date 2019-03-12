//
//  String+Extras.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data?.base64EncodedString() ?? ""
    }
}
