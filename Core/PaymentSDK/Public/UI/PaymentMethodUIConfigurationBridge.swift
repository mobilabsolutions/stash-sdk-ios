//
//  PaymentMethodUIConfigurationBridge.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 18/07/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import UIKit

@objc(MLPaymentMethodUIConfiguration) public class PaymentMethodUIConfigurationBridge: NSObject {
    let configuration: PaymentMethodUIConfiguration

    /// Initialize the payment method UI configuration
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color to use in the UI or `nil` for the default value
    ///   - textColor: The font color to use in the UI or `nil` for the default value
    ///   - buttonColor: The button color to use for enabled buttons in the UI or `nil` for the default value
    ///   - mediumEmphasisColor: The color to use for subtitles and other UI elements requiring medium emphasis
    ///                          or `nil` for the default value
    ///   - cellBackgroundColor: The background color to use for cells in the UI or `nil` for the default value
    ///   - buttonTextColor: The button text color to use in the UI or `nil` for the default value
    ///   - buttonDisabledColor: The button color to use when a button is disabled in the UI or `nil` for the default value
    @objc public required init(backgroundColor: UIColor?,
                               textColor: UIColor?,
                               buttonColor: UIColor?,
                               mediumEmphasisColor: UIColor?,
                               cellBackgroundColor: UIColor?,
                               buttonTextColor: UIColor?,
                               buttonDisabledColor: UIColor?,
                               errorMessageColor: UIColor?,
                               errorMessageTextColor: UIColor?) {
        self.configuration = PaymentMethodUIConfiguration(backgroundColor: backgroundColor,
                                                          textColor: textColor,
                                                          buttonColor: buttonColor,
                                                          mediumEmphasisColor: mediumEmphasisColor,
                                                          cellBackgroundColor: cellBackgroundColor,
                                                          buttonTextColor: buttonTextColor,
                                                          buttonDisabledColor: buttonDisabledColor,
                                                          errorMessageColor: errorMessageColor,
                                                          errorMessageTextColor: errorMessageTextColor)
    }

    init(configuration: PaymentMethodUIConfiguration) {
        self.configuration = configuration
    }
}
