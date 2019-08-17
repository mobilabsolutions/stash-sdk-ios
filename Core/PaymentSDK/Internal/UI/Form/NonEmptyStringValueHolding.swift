//
//  NonEmptyStringValueHolding.swift
//  StashCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct NonEmptyStringValueHolding {
    let string: String

    init?(string: String?) {
        guard let string = string, !string.isEmpty
        else { return nil }

        self.string = string
    }
}

extension NonEmptyStringValueHolding: PresentableValueHolding {
    var title: String {
        return self.string
    }

    var value: Any {
        return self.string
    }
}
