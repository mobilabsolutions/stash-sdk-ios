//
//  NameProvidingProtocol.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 29.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

@objc public protocol NameProviding: class {
    var firstName: String { get }
    var lastName: String { get }
    var fullName: String { get }
}
