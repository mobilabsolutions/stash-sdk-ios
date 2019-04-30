//
//  SimpleNameProvider.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 29.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public class SimpleNameProvider: NameProviding {
    public let firstName: String
    public let lastName: String

    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
