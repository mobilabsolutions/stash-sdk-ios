//
//  AliasResultCode.swift
//  MobilabPaymentCode
//
//  Created by Borna Beakovic on 12/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public enum AliasResultCode: String, Decodable {
    case authorised = "Authorised"
    case redirectShopper = "RedirectShopper"
    case identifyShopper = "IdentifyShopper"
    case challengeShopper = "ChallengeShopper"
}
