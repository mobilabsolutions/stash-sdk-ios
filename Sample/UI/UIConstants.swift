//
//  UIConstants.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

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
    
    public class var disabledColor: UIColor {
        return UIColor.black.withAlphaComponent(0.38)
    }
    
    public class var backButtonImage: UIImage? {
        guard let original = UIImage(named: "back-button", in: Bundle(for: UIConstants.self), compatibleWith: nil)
            else { return nil }
        return original.cgImage.flatMap { UIImage(cgImage: $0, scale: original.scale, orientation: .upMirrored).withRenderingMode(.alwaysOriginal) }
    }
    
    public class var closeButtonImage: UIImage? {
        guard let original = UIImage(named: "close-button", in: Bundle(for: UIConstants.self), compatibleWith: nil)
            else { return nil }
        return original.withRenderingMode(.alwaysOriginal)
    }
    
    public class var creditCardImage: UIImage? {
        return UIImage(named: "credit-card", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var sepaImage: UIImage? {
        return UIImage(named: "sepa", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var paypalImage: UIImage? {
        return UIImage(named: "paypal", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var rightArrowImage: UIImage? {
        return UIImage(named: "right-arrow", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var americanExpressImage: UIImage? {
        return UIImage(named: "american-express", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var dinersImage: UIImage? {
        return UIImage(named: "diners", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var mastercardImage: UIImage? {
        return UIImage(named: "mastercard", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var visaImage: UIImage? {
        return UIImage(named: "visa", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var maestroImage: UIImage? {
        return UIImage(named: "maestro", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var unionPayImage: UIImage? {
        return UIImage(named: "union-pay", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var discoverImage: UIImage? {
        return UIImage(named: "discover", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var carteBleueImage: UIImage? {
        return UIImage(named: "carte-bleue", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var jcbImage: UIImage? {
        return UIImage(named: "jcb", in: Bundle(for: UIConstants.self), compatibleWith: nil)
    }
    
    public class var searchImage: UIImage? {
        return UIImage(named: "search", in: Bundle(for: UIConstants.self), compatibleWith: nil)
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
        
        if let font = getFont() {
            return font
        }
        
        self.registerFontWithFilenameString("Lato-\(type.rawValue)")
        
        return getFont() ?? UIFont.systemFont(ofSize: size)
    }
    
    private static func registerFontWithFilenameString(_ filenameString: String) {
        let frameworkBundle = Bundle(for: UIConstants.self)
        
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
}
