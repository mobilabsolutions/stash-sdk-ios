//
//  CreditCardUtils.swift
//  MobilabPaymentCore
//
//  Created by Robert on 13.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public class CreditCardUtils {
    public static func formattedNumber(number: String) -> NSAttributedString {
        let cleaned = cleanedNumber(number: number)
        let type = cardTypeFromNumber(cleanedNumber: cleaned)
        return self.formattedNumber(number: cleaned, for: type)
    }

    public static func cardTypeFromNumber(number: String) -> CreditCardType {
        return self.cardTypeFromNumber(cleanedNumber: self.cleanedNumber(number: number))
    }

    public static func validateCVV(cvv: String) throws {
        guard let _ = Int(cvv), cvv.count == 3 || cvv.count == 4
        else { throw MobilabPaymentError.validation(.invalidCVV) }
    }

    public static func validateCreditCardNumber(cardNumber: String) throws {
        let cleanedNumber = CreditCardUtils.cleanedNumber(number: cardNumber)

        guard cleanedNumber.count > CreditCardData.numberOfDigitsForCardMask
        else { throw MobilabPaymentError.validation(.invalidCreditCardNumber) }

        guard CreditCardUtils.isLuhnValid(cleanedNumber: cleanedNumber)
        else { throw MobilabPaymentError.validation(.invalidCreditCardNumber) }
    }

    static func cardTypeFromNumber(cleanedNumber: String) -> CreditCardType {
        let highestPriorityMatch = cardNumbersAndRanges(for: cleanedNumber)
            .max { $0.0.priority < $1.0.priority }
        return highestPriorityMatch?.1 ?? .unknown
    }

    fileprivate static func cardNumbersAndRanges(for cleanedNumber: String) -> [(IINRange, CreditCardType)] {
        // Get card type from number using IIN ranges as documented here:
        // https://en.wikipedia.org/wiki/Payment_card_number#Major_Industry_Identifier_.28MII.29
        let numberLength = cleanedNumber.count

        guard numberLength > 6
        else { return [] }

        let iin = String(cleanedNumber[cleanedNumber.startIndex..<cleanedNumber.index(cleanedNumber.startIndex, offsetBy: 6)])
        return CreditCardType.allCases
            .flatMap { type in type.iinRangePatterns.map { (range: $0, type: type) } }
            .filter { range, _ in
                guard let relevantPart = Int(String(iin[iin.startIndex..<iin.index(iin.startIndex, offsetBy: range.priority)]))
                else { return false }
                return range.range ~= relevantPart && range.validLengths.contains { $0 ~= numberLength }
            }
    }

    static func cleanedNumber(number: String) -> String {
        return number.replacingOccurrences(of: "(\\s|\\-)", with: "", options: .regularExpression, range: nil)
    }

    static func isLuhnValid(cleanedNumber: String) -> Bool {
        guard cleanedNumber.unicodeScalars.reduce(true, { $0 && CharacterSet.decimalDigits.contains($1) })
        else { return false }

        let digits = cleanedNumber.compactMap { Int(String($0)) }
        let reversedDigitsWithoutCheck = digits.reversed().dropFirst()
        let doubledReversed = reversedDigitsWithoutCheck.enumerated().map { item -> Int in
            guard item.offset % 2 == 0
            else { return item.element }

            let doubled = item.element * 2

            guard doubled > 9
            else { return doubled }

            return doubled - 9
        }

        let checkDigit = (9 * doubledReversed.reduce(0, +)) % 10
        return checkDigit == digits.last
    }

    static func formattedNumber(number: String, for type: CreditCardType) -> NSAttributedString {
        let cleaned = cleanedNumber(number: number)
        let formattingSpaces = type.formattingSpaces

        let newString = NSMutableAttributedString(string: cleaned)

        for space in formattingSpaces {
            guard space < cleaned.count
            else { break }

            newString.addAttribute(.kern, value: 8.0, range: NSMakeRange(space - 1, 1))
        }

        return NSAttributedString(attributedString: newString)
    }
}

private struct IINRange {
    let range: ClosedRange<Int>
    /// The priority associated with this range. Higher number means higher priority. This is equivalent to the number of digits specified in the IIN.
    let priority: Int
    let validLengths: [ClosedRange<Int>]
}

extension CreditCardType {
    fileprivate var iinRangePatterns: [IINRange] {
        switch self {
        case .visa:
            return [IINRange(range: 4...4, priority: 1, validLengths: [13...13, 16...16, 18...18, 19...19])]
        case .mastercard:
            return [IINRange(range: 51...55, priority: 2, validLengths: [16...16]),
                    IINRange(range: 2221...2720, priority: 4, validLengths: [16...16])]
        case .americanExpress:
            return [IINRange(range: 34...34, priority: 2, validLengths: [15...15]),
                    IINRange(range: 37...37, priority: 2, validLengths: [15...15])]
        case .diners:
            return [IINRange(range: 36...36, priority: 2, validLengths: [14...19]),
                    IINRange(range: 300...305, priority: 3, validLengths: [14...19]),
                    IINRange(range: 3095...3095, priority: 4, validLengths: [14...19]),
                    IINRange(range: 38...39, priority: 2, validLengths: [14...19])]
        case .discover:
            return [IINRange(range: 6011...6011, priority: 4, validLengths: [16...19]),
                    IINRange(range: 622_126...622_925, priority: 6, validLengths: [16...19]),
                    IINRange(range: 624_000...626_999, priority: 6, validLengths: [16...19]),
                    IINRange(range: 628_200...628_899, priority: 6, validLengths: [16...19]),
                    IINRange(range: 64...65, priority: 2, validLengths: [16...19])]
        case .jcb:
            return [IINRange(range: 3528...3589, priority: 4, validLengths: [16...19])]
        case .maestroInternational:
            return [IINRange(range: 5018...5020, priority: 4, validLengths: [12...19]),
                    IINRange(range: 5038...5038, priority: 4, validLengths: [12...19]),
                    IINRange(range: 6304...6304, priority: 4, validLengths: [12...19]),
                    IINRange(range: 6307...6307, priority: 4, validLengths: [12...19]),
                    IINRange(range: 6759...6759, priority: 4, validLengths: [12...19]),
                    IINRange(range: 6761...6763, priority: 4, validLengths: [12...19])]
        case .chinaUnionPay:
            return [IINRange(range: 62...62, priority: 2, validLengths: [16...19])]
        case .unknown:
            return []
        }
    }
}

extension CreditCardType {
    fileprivate var formattingSpaces: [Int] {
        switch self {
        case .americanExpress: return [4, 10]
        default: return [4, 8, 12, 16]
        }
    }
}
