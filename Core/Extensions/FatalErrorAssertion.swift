//
//  FatalErrorAssertion.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 22/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

struct FatalErrorUtil {
    // 1
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    // 2
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    // 3
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        self.fatalErrorClosure = closure
    }

    // 4
    static func restoreFatalError() {
        self.fatalErrorClosure = self.defaultFatalErrorClosure
    }
}
