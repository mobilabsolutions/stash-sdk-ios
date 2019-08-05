//
//  FormConsumer.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.04.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

public typealias ValidationError = Error & CustomStringConvertible

public protocol FormConsumer: AnyObject {
    func consumeValues(data: [NecessaryData: String]) throws
    func validate(data: [NecessaryData: String]) -> FormConsumerError?
}

public struct FormConsumerError: Error {
    public let errors: [NecessaryData: ValidationError]

    public init(errors: [NecessaryData: ValidationError]) {
        self.errors = errors
    }
}
