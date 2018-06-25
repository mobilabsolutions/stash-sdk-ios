//
//  MLAddCreditCardResponseBS.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLAddCreditCardResponseBS: Mappable {
    
    private(set) var paymentAlias = ""
    private(set) var url = ""
    private(set) var merchantId = ""
    private(set) var action = ""
    private(set) var panAlias = ""
    private(set) var username = ""
    private(set) var password = ""
    private(set) var eventExtId = ""
    private(set) var currency = ""
    private(set) var amount = 0
    private(set) var kind = "creditcard"
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        paymentAlias <- map["paymentAlias"]
        url <- map["url"]
        merchantId <- map["merchantId"]
        action <- map["action"]
        panAlias <- map["panAlias"]
        username <- map["username"]
        password <- map["password"]
        eventExtId <- map["eventExtId"]
        currency <- map["currency"]
        amount <- map["amount"]
        kind = "creditcard"
    }
    
    func serializeXML(paymentMethod: MLPaymentMethod) -> String? {
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
