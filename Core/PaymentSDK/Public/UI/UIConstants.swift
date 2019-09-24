//
//  UIConstants.swift
//  StashBSPayone
//
//  Created by Robert on 21.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// UI Constants used by the SDK. Contains colors and image assets.
public final class UIConstants {
    public class var lightBlueGrey: UIColor {
        return UIColor(red: 209.0 / 255.0, green: 213.0 / 255.0, blue: 215.0 / 255.0, alpha: 1.0)
    }

    public class var coolGrey: UIColor {
        return UIColor(red: 163.0 / 255.0, green: 170.0 / 255.0, blue: 175.0 / 255.0, alpha: 1.0)
    }

    public class var iceBlue: UIColor {
        return UIColor(red: 246.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }

    public class var gunMetal: UIColor {
        return UIColor(red: 70.0 / 255.0, green: 84.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
    }

    public class var aquamarine: UIColor {
        return UIColor(red: 7.0 / 255.0, green: 208.0 / 255.0, blue: 199.0 / 255.0, alpha: 1.0)
    }

    public class var dark: UIColor {
        return UIColor(red: 18.0 / 255.0, green: 32.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0)
    }

    public class var trueBlue: UIColor {
        return UIColor(red: 7.0 / 255.0, green: 0.0 / 255.0, blue: 207.0 / 255.0, alpha: 1.0)
    }

    public class var veryLightPink: UIColor {
        return UIColor(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }

    public class var coral: UIColor {
        return UIColor(red: 239.0 / 255.0, green: 78.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
    }

    public class var salmon: UIColor {
        return UIColor(red: 248.0 / 255.0, green: 106.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0)
    }

    public class var disabledColor: UIColor {
        return UIColor.black.withAlphaComponent(0.38)
    }

    public class var darkRoyalBlue: UIColor {
        return UIColor(red: 0, green: 16.0 / 255.0, blue: 123.0 / 255.0, alpha: 1.0)
    }

    public class var clearBlue: UIColor {
        return UIColor(red: 46.0 / 255.0, green: 126.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
    }

    public class var lightishBlue: UIColor {
        return UIColor(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
    }

    public class var backButtonImage: UIImage? {
        guard let original = UIImage(named: "back-button", in: UIConstants.frameworkBundle(), compatibleWith: nil)
        else { return nil }
        return original.cgImage.flatMap {
            UIImage(cgImage: $0, scale: original.scale, orientation: .upMirrored)
                .withRenderingMode(.alwaysTemplate)
        }
    }

    public class var closeButtonImage: UIImage? {
        guard let original = UIImage(named: "close-button", in: UIConstants.frameworkBundle(), compatibleWith: nil)
        else { return nil }
        return original.withRenderingMode(.alwaysOriginal)
    }

    public class var creditCardImage: UIImage? {
        return UIImage(named: "creditCard", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var sepaImage: UIImage? {
        return UIImage(named: "sepa", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var sepaSmallImage: UIImage? {
        return UIImage(named: "sepaSmall", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalImage: UIImage? {
        return UIImage(named: "paypal", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalBigImage: UIImage? {
        return UIImage(named: "paypalBig", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalSmall: UIImage? {
        return UIImage(named: "paypalSmall", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var rightArrowImage: UIImage? {
        return UIImage(named: "right-arrow", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var solidArrowImage: UIImage? {
        return UIImage(named: "solid-arrow", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var americanExpressImage: UIImage? {
        return UIImage(named: "americanExpress", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var dinersImage: UIImage? {
        return UIImage(named: "dinersClub", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var mastercardImage: UIImage? {
        return UIImage(named: "mastercard", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var visaImage: UIImage? {
        return UIImage(named: "visa", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var maestroImage: UIImage? {
        return UIImage(named: "maestro", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var unionPayImage: UIImage? {
        return UIImage(named: "unionPay", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var discoverImage: UIImage? {
        return UIImage(named: "discover", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var jcbImage: UIImage? {
        return UIImage(named: "jcb", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var searchImage: UIImage? {
        return UIImage(named: "search", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var alertImage: UIImage? {
        return UIImage(named: "alert", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var crossImage: UIImage? {
        return UIImage(named: "cross", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalWithBackgroundImage: UIImage? {
        return UIImage(named: "payPalWithBackground", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var sepaWithBackgroundImage: UIImage? {
        return UIImage(named: "sepaWithBackground", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var detailsArrowImage: UIImage? {
        return UIImage(named: "detailsArrow", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var paymentSelectionIllustrationImage: UIImage? {
        return UIImage(named: "illustration", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalLogoNoTextImage: UIImage? {
        return UIImage(named: "payPalLogoNoText", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public class var payPalActivityIndicatorImage: UIImage? {
        return UIImage(named: "paypalActivityIndicator", in: UIConstants.frameworkBundle(), compatibleWith: nil)
    }

    public enum DefaultFontType: String {
        case black = "Black"
        case bold = "Bold"
        case regular = "Regular"
        case medium = "Medium"
        case heavy = "Heavy"
    }

    public class func defaultFont(of size: CGFloat, type: DefaultFontType = .regular) -> UIFont {
        func getFont() -> UIFont? {
            return UIFont(name: "Lato-\(type.rawValue)", size: size)
        }

        if let font = getFont() {
            return font
        }

        self.registerFontWithFilenameString("Lato-\(type.rawValue)")

        return getFont() ?? UIFont.systemFont(ofSize: size)
    }

    private static func registerFontWithFilenameString(_ filenameString: String) {
        let frameworkBundle = UIConstants.frameworkBundle()

        if !frameworkBundle.isLoaded {
            frameworkBundle.load()
        }

        guard let pathForResourceString = frameworkBundle.path(forResource: filenameString, ofType: "ttf"),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider)
        else { return }

        CTFontManagerRegisterGraphicsFont(fontRef, nil)
    }

    private static func frameworkBundle() -> Bundle {
        #if CARTHAGE
            return Bundle(for: UIConstants.self)
        #else
            guard let bundleUrl = Bundle(for: UIConstants.self).url(forResource: nil, withExtension: "bundle"),
                let bundle = Bundle(url: bundleUrl)
            else { fatalError("Could not retrieve bundle for framework") }
            return bundle
        #endif
    }
}
