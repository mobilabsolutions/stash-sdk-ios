//
//  Locale+Extension.swift
//  MobilabPaymentCore
//
//  Created by Rupali Ghate on 14.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

extension Locale {
    public func getAllCountriesWithCodes() -> ([Country]) {
        let countryCodes = Locale.isoRegionCodes
        let countryNames = countryCodes.map { Locale.current.localizedString(forRegionCode: $0) ?? $0 }

        var countries: [Country] = []

        for (index, name) in countryNames.enumerated() {
            let code = countryCodes[index]
            countries.append(Country(name: name, alpha2Code: code))
        }
        countries = countries.sorted(by: { $0.name < $1.name })
        return countries
    }

    public func getDeviceRegion() -> Country? {
        guard let countryCode = Locale.current.regionCode else { return nil }
        guard let countryName = Locale.current.localizedString(forRegionCode: countryCode) else { return nil }

        return Country(name: countryName, alpha2Code: countryCode)
    }
}
