//
//  SEPAUtils.swift
//  MobilabPaymentCore
//
//  Created by Robert on 13.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

/// Utilities for handling IBANs
public class SEPAUtils {
    /// Format an IBAN using NSAttributedString formatting options
    ///
    /// - Parameter number: The IBAN that should be formatted (may contain dashes and spaces)
    /// - Returns: The formatted IBAN
    public static func formattedIban(number: String) -> NSAttributedString {
        let cleaned = self.cleanedIban(number: number)
        let newString = NSMutableAttributedString(string: cleaned)

        for space in stride(from: 4, to: cleaned.count, by: 4) {
            newString.addAttribute(.kern, value: 8.0, range: NSMakeRange(space - 1, 1))
        }

        return NSAttributedString(attributedString: newString)
    }

    static func spaceFormattedIbanMask(number: String) -> String {
        let cleaned = self.cleanedIban(number: number)
        let middleStartIndex = cleaned.index(cleaned.startIndex, offsetBy: 2)
        let middleEndIndex = cleaned.index(cleaned.endIndex, offsetBy: -4)
        let firstDigits = String(cleaned[..<middleStartIndex])
        let lastDigits = String(cleaned[middleEndIndex..<cleaned.endIndex])

        return firstDigits + cleaned[middleStartIndex..<middleEndIndex].enumerated().reduce("") { acc, element in
            var acc = acc + "X"
            if (element.offset + firstDigits.count) % 4 == 3 {
                acc += " "
            }

            return acc
        } + lastDigits
    }

    static func cleanedIban(number: String) -> String {
        return number.replacingOccurrences(of: "(\\s|\\-)", with: "", options: .regularExpression, range: nil).uppercased()
    }

    /// Validate an IBAN's checksum validity
    ///
    /// - Parameter iban: The IBAN to validate (may contain dashes and spaces)
    /// - Throws: A `MobilabPaymentError.validation` error if the IBAN is not valid.
    public static func validateIBAN(iban: String) throws {
        let cleanedIban = SEPAUtils.cleanedIban(number: iban)
        guard SEPAUtils.isValid(cleanedNumber: cleanedIban)
        else { throw MobilabPaymentError.validation(.invalidIBAN).loggedError() }
    }

    static func isValid(cleanedNumber: String) -> Bool {
        guard cleanedNumber.isAlphaNumeric
        else { return false }

        guard SEPAUtils.isOfCorrectLength(number: cleanedNumber)
        else { return false }

        let firstFourCharacters = cleanedNumber[cleanedNumber.startIndex..<cleanedNumber.index(cleanedNumber.startIndex, offsetBy: 4)]
        let rest = cleanedNumber[cleanedNumber.index(cleanedNumber.startIndex, offsetBy: 4)..<cleanedNumber.endIndex]

        let updated = String(rest) + String(firstFourCharacters)
        let numerified = updated.compactMap { c -> String? in
            guard let firstScalar = c.unicodeScalars.first, firstScalar.isASCII, let A = "A".first?.unicodeScalars.first,
                let Z = "Z".first?.unicodeScalars.first
            else { return nil }

            guard firstScalar.value <= Z.value, firstScalar.value >= A.value
            else { return String(c) }

            return String(firstScalar.value - A.value + 10)
        }.joined()

        var current = String(numerified[numerified.startIndex..<numerified.index(numerified.startIndex, offsetBy: 9)])
        var left = numerified[numerified.index(numerified.startIndex, offsetBy: 9)..<numerified.endIndex]

        while !left.isEmpty {
            guard let currentInteger = Int(current)
            else { fatalError("It should now always be possible to create an integer from the IBAN parts") }

            let numberOfCharactersToUse = min(7, left.count)
            current = String(currentInteger % 97) + left[left.startIndex..<left.index(left.startIndex, offsetBy: numberOfCharactersToUse)]
            left = left[left.index(left.startIndex, offsetBy: numberOfCharactersToUse)..<left.endIndex]
        }

        guard let currentInteger = Int(current)
        else { fatalError("It should now always be possible to create an integer from the IBAN parts") }

        return currentInteger % 97 == 1
    }

    /// IBAN lengths taken from https://www.iban.com/structure
    private static let ibanLengths = [
        "NO": 15, "BE": 16, "DK": 18, "FI": 18, "FO": 18, "GL": 18, "NL": 18, "MK": 19,
        "SI": 19, "AT": 20, "BA": 20, "EE": 20, "KZ": 20, "LT": 20, "LU": 20, "CR": 21,
        "CH": 21, "HR": 21, "LI": 21, "LV": 21, "BG": 22, "BH": 22, "DE": 22, "GB": 22,
        "GE": 22, "IE": 22, "ME": 22, "RS": 22, "AE": 23, "GI": 23, "IL": 23, "AD": 24,
        "CZ": 24, "ES": 24, "MD": 24, "PK": 24, "RO": 24, "SA": 24, "SE": 24, "SK": 24,
        "VG": 24, "TN": 24, "PT": 25, "IS": 26, "TR": 26, "FR": 27, "GR": 27, "IT": 27,
        "MC": 27, "MR": 27, "SM": 27, "AL": 28, "AZ": 28, "CY": 28, "DO": 28, "GT": 28,
        "HU": 28, "LB": 28, "PL": 28, "BR": 29, "PS": 29, "KW": 30, "MU": 30, "MT": 31,
        "SV": 28, "UA": 29, "TL": 23, "SC": 31, "ST": 25, "LC": 32, "QA": 29, "XK": 20,
        "JO": 30, "IQ": 23, "BY": 28,
    ]

    private static func isOfCorrectLength(number: String) -> Bool {
        guard let countryIdentifierEndIndex = number.index(number.startIndex, offsetBy: 2, limitedBy: number.endIndex)
        else { return false }

        return number.count == self.ibanLengths[String(number[number.startIndex..<countryIdentifierEndIndex])]
    }
}
