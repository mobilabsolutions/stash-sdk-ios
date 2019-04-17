//
//  PatternUtilities.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 04.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

func isContainedIn<T: Hashable, S: Collection>(_ collection: S) -> (T) -> Bool where S.Element == T {
    return { v in collection.contains(v) }
}

func ~= <T>(pattern: (T) -> Bool, value: T) -> Bool {
    return pattern(value)
}
