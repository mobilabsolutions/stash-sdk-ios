//
//  PaymentMethodUIConfiguration.swift
//  StashCore
//
//  Created by Robert on 25.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

/// The payment method UI configuration. Can be used to customize the way the SDK UI is styled.
public struct PaymentMethodUIConfiguration {
    /// The background color that should be used
    public let backgroundColor: UIColor
    /// The text color that should be used for most labels
    public let textColor: UIColor
    /// The color the done button should have when enabled
    public let buttonColor: UIColor
    /// The color the done button should have when disabled
    public let buttonDisabledColor: UIColor
    /// The color of text field borders, etc.
    public let mediumEmphasisColor: UIColor
    /// The color that cell backgrounds should have in the forms
    public let cellBackgroundColor: UIColor
    /// The text color for the button to use
    public let buttonTextColor: UIColor
    /// The color in which error messages should be presented, will also be used as background color for the error alert
    public let errorMessageColor: UIColor
    /// The color that the error alert text should be styled in
    public let errorMessageTextColor: UIColor

    public static let defaultBackgroundColor = UIConstants.iceBlue
    public static let defaultTextColor = UIConstants.dark
    public static let defaultButtonColor = UIConstants.aquamarine
    public static let defaultMediumEmphasisColor = UIConstants.coolGrey
    public static let defaultCellBackgroundColor = UIColor.white
    public static let defaultButtonTextColor = UIColor.white
    public static let defaultButtonDisabledColor = UIConstants.disabledColor
    public static let defaultErrorMessageColor = UIConstants.salmon
    public static let defaultErrorMessageTextColor = UIColor.white

    /// Create a new instance of a PaymentMethodUIConfiguration. Provide those values that should be changed, others will keep the default value.
    public init(backgroundColor: UIColor = PaymentMethodUIConfiguration.defaultBackgroundColor,
                textColor: UIColor = PaymentMethodUIConfiguration.defaultTextColor,
                buttonColor: UIColor = PaymentMethodUIConfiguration.defaultButtonColor,
                mediumEmphasisColor: UIColor = PaymentMethodUIConfiguration.defaultMediumEmphasisColor,
                cellBackgroundColor: UIColor = PaymentMethodUIConfiguration.defaultCellBackgroundColor,
                buttonTextColor: UIColor = PaymentMethodUIConfiguration.defaultButtonTextColor,
                buttonDisabledColor: UIColor = PaymentMethodUIConfiguration.defaultButtonDisabledColor,
                errorMessageColor: UIColor = PaymentMethodUIConfiguration.defaultErrorMessageColor,
                errorMessageTextColor: UIColor = PaymentMethodUIConfiguration.defaultErrorMessageTextColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.buttonColor = buttonColor
        self.mediumEmphasisColor = mediumEmphasisColor
        self.cellBackgroundColor = cellBackgroundColor
        self.buttonTextColor = buttonTextColor
        self.buttonDisabledColor = buttonDisabledColor
        self.errorMessageColor = errorMessageColor
        self.errorMessageTextColor = errorMessageTextColor
    }

    init(backgroundColor: UIColor?,
         textColor: UIColor?,
         buttonColor: UIColor?,
         mediumEmphasisColor: UIColor?,
         cellBackgroundColor: UIColor?,
         buttonTextColor: UIColor?,
         buttonDisabledColor: UIColor?,
         errorMessageColor: UIColor?,
         errorMessageTextColor: UIColor?) {
        self.backgroundColor = backgroundColor ?? PaymentMethodUIConfiguration.defaultBackgroundColor
        self.textColor = textColor ?? PaymentMethodUIConfiguration.defaultTextColor
        self.buttonColor = buttonColor ?? PaymentMethodUIConfiguration.defaultButtonColor
        self.mediumEmphasisColor = mediumEmphasisColor ?? PaymentMethodUIConfiguration.defaultMediumEmphasisColor
        self.cellBackgroundColor = cellBackgroundColor ?? PaymentMethodUIConfiguration.defaultCellBackgroundColor
        self.buttonTextColor = buttonTextColor ?? PaymentMethodUIConfiguration.defaultButtonTextColor
        self.buttonDisabledColor = buttonDisabledColor ?? PaymentMethodUIConfiguration.defaultButtonDisabledColor
        self.errorMessageTextColor = errorMessageTextColor ?? PaymentMethodUIConfiguration.defaultErrorMessageTextColor
        self.errorMessageColor = errorMessageColor ?? PaymentMethodUIConfiguration.defaultErrorMessageColor
    }
}
