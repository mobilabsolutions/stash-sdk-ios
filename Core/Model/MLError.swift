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
public class MLError: MLErrorProtocol {
    /// The error's title. Provides some context to the error.
    public let title: String
    /// The unique code identigying the error
    public let code: Int
    /// A string describing the error and reasoning for it
    public let errorDescription: String

    public init(title: String, description: String, code: Int) {
        self.title = title
        self.code = code
        self.errorDescription = description
    }

    public init(description: String, code: Int) {
        self.title = "MobilabPayment Error"
        self.errorDescription = description
        self.code = code
    }
}
