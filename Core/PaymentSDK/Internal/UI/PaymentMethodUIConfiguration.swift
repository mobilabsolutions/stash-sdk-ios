//
//  PaymentMethodUIConfiguration.swift
//  MobilabPaymentCore
//
//  Created by Robert on 25.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import UIKit

public struct PaymentMethodUIConfiguration {
    public let backgroundColor: UIColor
    public let textColor: UIColor
    public let buttonColor: UIColor
    public let buttonDisabledColor: UIColor
    public let mediumEmphasisColor: UIColor
    public let cellBackgroundColor: UIColor
    public let buttonTextColor: UIColor
    public let errorMessageColor: UIColor
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

    public init(backgroundColor: UIColor?,
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
