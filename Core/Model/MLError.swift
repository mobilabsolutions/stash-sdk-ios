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

public class MLError: MLErrorProtocol {
    public let title: String
    public let code: Int
    public var errorDescription: String? { return self._description }
    public var failureReason: String? { return self._description }

    private let _description: String

    public init(title: String, description: String, code: Int) {
        self.title = title
        self.code = code
        self._description = description
    }

    public init(description: String, code: Int) {
        self.title = "MobilabPayment Error"
        self._description = description
        self.code = code
    }
}
