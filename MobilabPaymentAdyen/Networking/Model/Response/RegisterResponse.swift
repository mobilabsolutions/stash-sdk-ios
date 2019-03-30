//
//  RegisterCreditCardResponse.swift
//  MobilabPaymentBSPayone
//
//  Created by Borna Beakovic on 01/03/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation
import MobilabPaymentCore

enum ResultCode: String, Codable {
    case authorised = "Authorised"
    case refused = "Refused"
    case redirectShopper = "RedirectShopper"
    case received = "Received"
    case cancelled = "Cancelled"
    case pending = "Pending"
    case error = "Error"
}

struct RegisterResponse {
    let resultCode: ResultCode
    let pspReference: String

    init(resultCode: ResultCode, pspReference: String) {
        self.resultCode = resultCode
        self.pspReference = pspReference
    }
}

extension RegisterResponse: Decodable {
    enum DecodableKeys: String, CodingKey {
        case resultCode
        case pspReference
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableKeys.self)
        let resultCode: ResultCode = try container.decode(ResultCode.self, forKey: .resultCode)
        switch resultCode {
        case .authorised, .received:
            let pspReference: String = try container.decode(String.self, forKey: .pspReference)
            self.init(resultCode: resultCode, pspReference: pspReference)
        default:
            throw NetworkClientError.shouldTryDecodingErrorResponse
        }
    }
}
