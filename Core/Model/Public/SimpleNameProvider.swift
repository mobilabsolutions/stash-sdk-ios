//
//  SimpleNameProvider.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 29.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

@objc(MLSimpleNameProvider) public class SimpleNameProvider: NSObject, NameProviding {
    public let firstName: String
    public let lastName: String

    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    @objc public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
