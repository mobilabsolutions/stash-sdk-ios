//
//  CountryListCollectionViewControllerDelegate.swift
//  Stash
//
//  Created by Robert on 03.09.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation
import StashCore

// MARK: - Protocol

protocol CountryListCollectionViewControllerDelegate: AnyObject {
    func didSelectCountry(country: Country)
}
