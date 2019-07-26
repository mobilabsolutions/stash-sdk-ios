//
//  AliasCreationDetail.swift
//  MobilabPaymentCore
//
//  Created by Robert on 15.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A superclass for all custom PSP creation details that should be sent during the createAlias call.
open class AliasCreationDetail: Codable {
    /// Create an empty AliasCreationDetail
    public init() {}
}
