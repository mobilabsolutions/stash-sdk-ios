//
//  MobilabBraintreeBridge.swift
//  MobilabPaymentBraintree
//
//  Created by Borna Beakovic on 20/03/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import MobilabPaymentCore
import UIKit

/// A bridge that allows usage and creation of instanes of the Braintree module from Objective-C
@objc(MLMobilabBraintree) public class MobilabBraintreeBridge: NSObject {
    /// Create a Braintree module instance from Objective-C. This instance can be used to initialize the SDK.
    ///
    /// - Parameter urlScheme: The registered URL scheme.
    /// See [here](https://github.com/mobilabsolutions/payment-sdk-ios-open#paypal-account-registration) for more considerations.
    /// - Returns: The created Braintree module
    @objc public static func createModule(urlScheme: String) -> PaymentProviderBridge {
        return PaymentProviderBridge(paymentProvider: MobilabPaymentBraintree(urlScheme: urlScheme))
    }

    /// Handle a potential Braintree URL redirection that comes in via the UIApplicationDelegate's `application(_:open:options:)`
    ///
    /// - Parameters:
    ///   - url: The url as provided by the UIApplicationDelegate method
    ///   - options: The options as provided by the UIApplicationDelegate method
    /// - Returns: A boolean indicating whether or not the Braintree module handled the request.
    @objc public static func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return MobilabPaymentBraintree.handleOpen(url: url, options: options)
    }
}
