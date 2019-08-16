//
//  CreditCardType+Extensions.swift
//  StashBSPayone
//
//  Created by Robert on 26.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

public extension CreditCardType {
    /// A logo image associated with the given credit card type
    var image: UIImage? {
        switch self {
        case .visa: return UIConstants.visaImage
        case .mastercard: return UIConstants.mastercardImage
        case .americanExpress: return UIConstants.americanExpressImage
        case .diners: return UIConstants.dinersImage
        case .discover: return UIConstants.discoverImage
        case .jcb: return UIConstants.jcbImage
        case .maestroInternational: return UIConstants.maestroImage
        case .chinaUnionPay: return UIConstants.unionPayImage
        case .unknown: return UIConstants.creditCardImage
        }
    }
}
