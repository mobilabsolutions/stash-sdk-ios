//
//  StashErrorBridge.swift
//  StashCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// A bridge that allows accessing `StashError`s from Objective-C
@objc(MLError) public class StashErrorBridge: NSObject {
    /// The original error's title
    @objc public let title: String
    /// The original error's description
    @objc public let errorDescription: String

    /// Create a bridge instance from an original error
    ///
    /// - Parameter stashError: The original error
    public init(stashError: StashError) {
        self.title = stashError.title
        self.errorDescription = stashError.description
        super.init()
    }
}
