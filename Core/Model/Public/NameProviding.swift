//
//  NameProvidingProtocol.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 29.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A protocol to describe real world names. This allows custom name representations.
@objc public protocol NameProviding: AnyObject {
    /// The first name (given name)
    var firstName: String { get }
    /// The last name (surname)
    var lastName: String { get }
    /// The full name
    var fullName: String { get }
}
