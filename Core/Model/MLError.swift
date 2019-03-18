//
//  MLError.swift
//  GithubProject
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 Mirza Zenunovic. All rights reserved.
//

import Foundation

protocol MLErrorProtocol: LocalizedError {
    var title: String { get }
    var code: Int { get }
}

/// An error that occurred in the MobilabPaymentSDK
@objc public class MLError: NSObject, MLErrorProtocol {
    /// The error's title. Provides some context to the error.
    @objc public let title: String
    /// The unique code identigying the error
    @objc public let code: Int
    /// A string describing the error and reasoning for it
    @objc public let errorDescription: String

    @objc public var failureReason: String? {
        return self.errorDescription
    }

    @objc public init(title: String, description: String, code: Int) {
        self.title = title
        self.code = code
        self.errorDescription = description
    }

    @objc public init(description: String, code: Int) {
        self.title = "MobilabPayment Error"
        self.errorDescription = description
        self.code = code
    }
}
