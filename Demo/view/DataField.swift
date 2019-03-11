//
//  DataField.swift
//  Demo
//
//  Created by Robert on 11.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import MobilabPaymentCore
import UIKit

protocol DataField where Self: UIView {
    var delegate: DataFieldDelegate? { get set }
    func clearInputs()
}

protocol DataFieldDelegate: class {
    func addCreditCard(method: CreditCardData, billingData: BillingData)
    func addSEPA(method: SEPAData, billingData: BillingData)
}
