//
//  IntValueHolding.swift
//  MobilabPaymentCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct IntValueHolding {
    let int: Int

    init?(int: Int?) {
        guard let int = int
        else { return nil }

        self.int = int
    }
}

extension IntValueHolding: PresentableValueHolding {
    var title: String {
        return String(self.int)
    }

    var value: Any {
        return self.int
    }
}
