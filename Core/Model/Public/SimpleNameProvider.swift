//
//  SimpleNameProvider.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 29.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A name provider that simply concatenates first and last name using a space character
@objc(MLSimpleNameProvider) public class SimpleNameProvider: NSObject, NameProviding {
    /// The first name
    public let firstName: String
    /// The last name
    public let lastName: String

    /// First name and last name concatenated using a space
    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    /// Create a new name provider
    ///
    /// - Parameters:
    ///   - firstName: The first name
    ///   - lastName: The last name
    @objc public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
