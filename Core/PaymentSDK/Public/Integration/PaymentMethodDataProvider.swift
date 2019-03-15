//
//  PaymentMethodProvidable.swift
//  MobilabPaymentCore
//
//  Created by Robert on 14.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public protocol PaymentMethodDataProvider {
    var didCreatePaymentMethodCompletion: ((RegistrationData) -> Void)? { get set }
}
