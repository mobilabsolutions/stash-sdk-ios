//
//  MLError.swift
//  GithubProject
//
//  Created by Mirza Zenunovic on 14/06/2018.
//  Copyright © 2018 Mirza Zenunovic. All rights reserved.
//

import Foundation

protocol MLErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

public class MLError: NSObject, MLErrorProtocol {
    var title: String?
    var code: Int
    public var errorDescription: String? { return self._description }
    public var failureReason: String? { return self._description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
