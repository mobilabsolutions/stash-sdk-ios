//
//  CreditCardType+Extensions.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 26.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import MobilabPaymentUI

extension CreditCardData.CreditCardType {
    var image: UIImage? {
        switch self {
        case .visa: return UIConstants.visaImage
        case .mastercard: return UIConstants.mastercardImage
        case .americanExpress: return UIConstants.americanExpressImage
        case .diners: return UIConstants.dinersImage
        case .discover: return UIConstants.discoverImage
        case .jcb: return UIConstants.jcbImage
        case .maestroInternational: return UIConstants.maestroImage
        case .carteBleue: return UIConstants.carteBleueImage
        case .chinaUnionPay: return UIConstants.unionPayImage
        case .unknown: return UIConstants.creditCardImage
        }
    }
}
