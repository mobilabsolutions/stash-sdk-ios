//
//  MLAddCreditCardResponseHC.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLAddCreditCardResponseHC: MLAddCreditCardResponse {

    override init() {
        super.init()
    }
    
    override func serializeXML(paymentMethod: MLPaymentMethod) -> String? {
        guard let methodData = paymentMethod.methodData as? MLCreditCardData else { return nil }
        let xmlEnvelope = """
        <payment>
        <payment_method>credit_card</payment_method>
        <card_holder>\(methodData.holderName)</card_holder>
        <card_number>\(methodData.cardNumber)</card_number>
        <cvv>\(methodData.CVV)</cvv>
        <expiration_year>\(methodData.expiryYear)</expiration_year>
        <expiration_month>\(methodData.expiryMonth)</expiration_month>
        </payment>
        """
        return xmlEnvelope
    }
}
