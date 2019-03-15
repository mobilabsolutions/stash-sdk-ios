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

@objc public class MLError: NSObject, MLErrorProtocol {
    @objc public let title: String
    @objc public let code: Int
    @objc public var errorDescription: String? { return self._description }
    @objc public var failureReason: String? { return self._description }

    private let _description: String

    @objc public init(title: String, description: String, code: Int) {
        self.title = title
        self.code = code
        self._description = description
    }

    @objc public init(description: String, code: Int) {
        self.title = "MobilabPayment Error"
        self._description = description
        self.code = code
    }
}
