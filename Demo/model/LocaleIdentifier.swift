//
//  LocaleIdentifier.swift
//  Demo
//
//  Created by Rupali Ghate on 24.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

enum LocaleIdentifier: String {
    case germany
    case usa
    case uk
}

extension LocaleIdentifier {
    var identifier: String {
        switch self {
        case .germany:
            return "de-de"
        case .uk:
            return "en_uk"
        case .usa:
            return "en_us"
        }
    }
}
