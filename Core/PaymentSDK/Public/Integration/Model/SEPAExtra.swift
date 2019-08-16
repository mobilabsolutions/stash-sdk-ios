//
//  SEPAExtra.swift
//  StashCore
//
//  Created by Robert on 03.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A model that contains all extra information that should be
/// propagated to the payment SDK backend when registering a SEPA method.
/// This will and should not be used by clients directly but only by
/// the core SDK and modules.
public struct SEPAExtra: Codable {
    /// The IBAN for the SEPA payment method
    public let iban: String
    /// The BIC for the SEPA payment method
    public let bic: String?
}
