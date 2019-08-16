//
//  CountryInputPresentingDelegate.swift
//  StashCore
//
//  Created by Robert on 02.08.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

protocol CountryInputPresentingDelegate: class {
    func presentCountryInput(countryDelegate: CountryListCollectionViewControllerDelegate)
}
