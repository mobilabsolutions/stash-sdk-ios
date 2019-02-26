//
//  MLAddCreditCardResponseBS.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 26/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

class MLAddCreditCardResponseBS: MLAddCreditCardResponse {
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func serializeXML(paymentMethod: MLPaymentMethod) -> String? {
        guard let methodData = paymentMethod.methodData as? MLCreditCardData else { return nil }
        let xmlEnvelope = """
        <?xml version=\"1.0\"?>
        <soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns=\"http://www.voeb-zvd.de/xmlapi/1.0\">
        <soap:Header/>
        <soap:Body>
        <ns:xmlApiRequest version=\"1.6\" id=\"a1\">
        <ns:paymentRequest id=\"b1\">
        <ns:merchantId>\(merchantId)</ns:merchantId>
        <ns:eventExtId>\(eventExtId)</ns:eventExtId>
        <ns:kind>\(kind)</ns:kind>
        <ns:action>\(action)</ns:action>
        <ns:amount>\(amount)</ns:amount>
        <ns:currency>\(currency)</ns:currency>
        <ns:creditCard>
        <ns:pan>\(methodData.cardNumber)</ns:pan>
        <ns:panalias generate=\"true\">\(panAlias)</ns:panalias>
        <ns:expiryDate>
        <ns:month>\(methodData.expiryMonth)</ns:month>
        <ns:year>\(methodData.expiryYear)</ns:year>
        </ns:expiryDate>
        <ns:holder>\(methodData.holderName)</ns:holder>
        <ns:verificationCode>\(methodData.CVV)</ns:verificationCode>
        </ns:creditCard>
        </ns:paymentRequest>
        </ns:xmlApiRequest>
        </soap:Body>
        </soap:Envelope>
        """
        return xmlEnvelope
    }

    func serializeXMLForAlias(paymentMethod: MLPaymentMethod) -> String? {
        guard let methodData = paymentMethod.methodData as? MLCreditCardData else { return nil }
        let xmlEnvelope = """
        <soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:ns=\"http://www.voeb-zvd.de/xmlapi/1.0\">
        <soap:Header/>
        <soap:Body>
        <ns:xmlApiRequest version=\"1.6\" id=\"a1\">
        <ns:panAliasRequest id=\"a12\">
        <ns:merchantId>\(merchantId)</ns:merchantId>
        <ns:action>info</ns:action>
        <ns:pan>\(methodData.cardNumber)</ns:pan>
        <ns:expiryDate>
        <ns:month>\(methodData.expiryMonth)</ns:month>
        <ns:year>\(methodData.expiryYear)</ns:year>
        </ns:expiryDate>
        </ns:panAliasRequest>
        </ns:xmlApiRequest>
        </soap:Body>
        </soap:Envelope>
        """
        return xmlEnvelope
    }
}
