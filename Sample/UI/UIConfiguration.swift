//
//  UIConfiguration.swift
//  Sample
//
//  Created by Rupali Ghate on 08.05.19.
//  Copyright © 2019 Rupali Ghate. All rights reserved.
//

import UIKit

struct UIConfiguration {
    #warning("should add screen titleColor in configuration")
    
    public let backgroundColor: UIColor
    public let textColor: UIColor
    public let buttonColor: UIColor
    public let buttonDisabledColor: UIColor
    public let mediumEmphasisColor: UIColor
    public let cellBackgroundColor: UIColor
    public let buttonTextColor: UIColor
    
    public static let defaultBackgroundColor = UIConstants.iceBlue
    public static let defaultTextColor = UIConstants.dark
    public static let defaultButtonColor = UIConstants.aquamarine
    public static let defaultMediumEmphasisColor = UIConstants.coolGrey
    public static let defaultCellBackgroundColor = UIColor.white
    public static let defaultButtonTextColor = UIColor.white
    public static let defaultButtonDisabledColor = UIConstants.disabledColor
    
    public init(backgroundColor: UIColor = UIConfiguration.defaultBackgroundColor,
                textColor: UIColor = UIConfiguration.defaultTextColor,
                buttonColor: UIColor = UIConfiguration.defaultButtonColor,
                mediumEmphasisColor: UIColor = UIConfiguration.defaultMediumEmphasisColor,
                cellBackgroundColor: UIColor = UIConfiguration.defaultCellBackgroundColor,
                buttonTextColor: UIColor = UIConfiguration.defaultButtonTextColor,
                buttonDisabledColor: UIColor = UIConfiguration.defaultButtonDisabledColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.buttonColor = buttonColor
        self.mediumEmphasisColor = mediumEmphasisColor
        self.cellBackgroundColor = cellBackgroundColor
        self.buttonTextColor = buttonTextColor
        self.buttonDisabledColor = buttonDisabledColor
    }
    
    public init(backgroundColor: UIColor?,
                textColor: UIColor?,
                buttonColor: UIColor?,
                mediumEmphasisColor: UIColor?,
                cellBackgroundColor: UIColor?,
                buttonTextColor: UIColor?,
                buttonDisabledColor: UIColor?) {
        self.backgroundColor = backgroundColor ?? UIConfiguration.defaultBackgroundColor
        self.textColor = textColor ?? UIConfiguration.defaultTextColor
        self.buttonColor = buttonColor ?? UIConfiguration.defaultButtonColor
        self.mediumEmphasisColor = mediumEmphasisColor ?? UIConfiguration.defaultMediumEmphasisColor
        self.cellBackgroundColor = cellBackgroundColor ?? UIConfiguration.defaultCellBackgroundColor
        self.buttonTextColor = buttonTextColor ?? UIConfiguration.defaultButtonTextColor
        self.buttonDisabledColor = buttonDisabledColor ?? UIConfiguration.defaultButtonDisabledColor
    }
}
