//
//  UIConstants.swift
//  Demo
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import StashCore
import UIKit

extension UIConstants {
    class var itemsImage: UIImage? {
        return UIImage(named: "items", in: Bundle.main, compatibleWith: nil)
    }

    class var paymentImage: UIImage? {
        return UIImage(named: "payment", in: Bundle.main, compatibleWith: nil)
    }

    class var checkoutImage: UIImage? {
        return UIImage(named: "checkout", in: Bundle.main, compatibleWith: nil)
    }

    class var deleteImage: UIImage? {
        return UIImage(named: "delete", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    class var addImage: UIImage? {
        return UIImage(named: "add", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    class var removeImage: UIImage? {
        return UIImage(named: "remove", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    class var emptyCartImage: UIImage? {
        return UIImage(named: "illustrationEmptyCart", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    class var selectedImage: UIImage? {
        return UIImage(named: "selected", in: Bundle.main, compatibleWith: nil)
    }

    class var unSelectedImage: UIImage? {
        return UIImage(named: "unselected", in: Bundle.main, compatibleWith: nil)
    }

    class var infoImage: UIImage? {
        return UIImage(named: "info", in: Bundle.main, compatibleWith: nil)
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
