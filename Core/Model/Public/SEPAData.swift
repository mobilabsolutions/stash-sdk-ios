//
//  MLSEPAData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 19/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol SEPADataInitializible {
    init(iban: String, bic: String?, billingData: BillingData) throws
}

/// SEPAData contains all data necessary for registering a SEPA account with a payment service provider
public struct SEPAData: RegistrationData, SEPADataInitializible {
    /// The BIC (Bank Identifier Code) associated with the SEPA account
    public let bic: String?
    /// The IBAN (International Bank Account Number) associated with the SEPA account
    public let iban: String
    /// The billing data to use when registering the SEPA account with a payment service provider
    public let billingData: BillingData

    /// Create new SEPA data using necessary data
    ///
    /// - Parameters:
    ///   - iban: The IBAN
    ///   - bic: The BIC
    ///   - billingData: The billing data that should be taken into account
    /// - Throws: A validation error if the payment method is not valid
    public init(iban: String, bic: String?, billingData: BillingData) throws {
        let cleanedIban = SEPAUtils.cleanedIban(number: iban)
        try SEPAUtils.validateIBAN(iban: cleanedIban)

        self.iban = cleanedIban
        self.bic = bic
        self.billingData = billingData
    }

    /// Create a SEPA extra from this payment method
    ///
    /// - Returns: The SEPA extra
    public func toSEPAExtra() -> SEPAExtra {
        return SEPAExtra(iban: self.iban, bic: self.bic)
    }

    /// Extract the usable extra alias info for this payment method
    public var extraAliasInfo: PaymentMethodAlias.ExtraAliasInfo {
        let formatted = SEPAUtils.spaceFormattedIbanMask(number: self.iban)
        let extra = PaymentMethodAlias.SEPAExtraInfo(maskedIban: formatted)
        return .sepa(extra)
    }
}
