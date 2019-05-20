//
//  UIConstants.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import MobilabPaymentCore
import UIKit

extension UIConstants {
    public class var itemsImage: UIImage? {
        return UIImage(named: "items", in: Bundle.main, compatibleWith: nil)
    }

    public class var paymentImage: UIImage? {
        return UIImage(named: "payment", in: Bundle.main, compatibleWith: nil)
    }

    public class var checkoutImage: UIImage? {
        return UIImage(named: "checkout", in: Bundle.main, compatibleWith: nil)
    }

    public class var deleteImage: UIImage? {
        return UIImage(named: "delete", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    public class var addImage: UIImage? {
        return UIImage(named: "add", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    enum DefaultFontType: String {
        case black = "Black"
        case bold = "Bold"
        case regular = "Regular"
        case medium = "Medium"
    }

    class func defaultFont(of size: CGFloat, type: DefaultFontType = .regular) -> UIFont {
        func getFont() -> UIFont? {
            return UIFont(name: "Lato-\(type.rawValue)", size: size)
        }
        return getFont() ?? UIFont.systemFont(ofSize: size)
    }
}
