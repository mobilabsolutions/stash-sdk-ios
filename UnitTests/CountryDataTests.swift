//
//  CountryDataTests.swift
//  MobilabPaymentTests
//
//  Created by Rupali Ghate on 15.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

@testable import MobilabPaymentCore
import XCTest

class CountryDataTests: XCTestCase {
    func testShouldCorrectlyReadsCountries() {
        let countries = Locale.current.getAllCountriesWithCodes()
        XCTAssertFalse(countries.isEmpty)
    }

    func testShouldNotContainEmptyFields() {
        let countries = Locale.current.getAllCountriesWithCodes()

        let resultForEmptyFields = countries.filter { (country) -> Bool in
            country.name.isEmpty || country.alpha2Code.isEmpty
        }
        XCTAssertTrue(resultForEmptyFields.isEmpty)
    }
}
