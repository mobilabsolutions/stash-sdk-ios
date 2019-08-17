//
//  CountryValueHolding.swift
//  StashCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

struct CountryValueHolding {
    let country: Country
}

extension CountryValueHolding: PresentableValueHolding {
    var title: String {
        return self.country.name
    }

    var value: Any {
        return self.country
    }
}
