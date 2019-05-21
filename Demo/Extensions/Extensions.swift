//
//  Extensions.swift
//  Demo
//
//  Created by Rupali Ghate on 20.05.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

extension Float {
    func toCurrency(with currencySign: String = "$") -> String {
        var separator = "."
        switch currencySign {
        case "€": separator = ","
        default:
            break
        }

        // placement of currency sign (before or after the number) and decimal seperator
        let formattedCurrency = currencySign == "€" ? "\(String(self).replacingOccurrences(of: ".", with: separator)) \(currencySign)" :
            "\(currencySign) \(String(self))"

        return formattedCurrency
    }
}
