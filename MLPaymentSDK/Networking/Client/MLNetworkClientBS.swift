//
//  MLNetworkClientBS.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLNetworkClientBS: MLNetworkClient {
    
    override func addMethod(paymentMethod: MLPaymentMethod, success: Success<String>, failiure: Failiure) {
        
        switch paymentMethod.requestData.type {
        
            case MLPaymentMethodType.MLCreditCard:
                addCreditCard(paymentMethod: paymentMethod, success: { [unowned self] creditCardResponse in
                    print(creditCardResponse)
                    self.finishMethodTransaction(paymentMethod: paymentMethod,
                                                 creditCardResponse: creditCardResponse,
                                                 success: success,
                                                 failiure: failiure)
                }, failiure: failiure)
            
            case MLPaymentMethodType.MLSEPA:
                addSEPA(paymentMethod: paymentMethod, success: { creditCardResponse in
                    print(creditCardResponse)
                    //TODO: Check panAlias it is "" for some reason
                    success?(creditCardResponse.panAlias)
                    }, failiure: failiure)
            
            case MLPaymentMethodType.MLPayPal:
                print("Not implemented")
                return
        }
    }
}

private extension MLNetworkClientBS {
    
    func addCreditCard(paymentMethod: MLPaymentMethod, success: Success<MLAddCreditCardResponseBS>, failiure: Failiure) {
        let requestObject = MLCreditCardRequest(paymentMethod: paymentMethod)
        MLURLSessionManager.request(request: RouterRequest.addCreditCard(requestObject), success: { data in
            if let ccResponse = MLAddCreditCardResponseBS.parse(data, key: "result") {
                success?(ccResponse)
            }
        }, failure: failiure)
    }
    
    func addSEPA(paymentMethod: MLPaymentMethod, success: Success<MLAddCreditCardResponseBS>, failiure: Failiure) {
        let requestObject = MLSEPARequest(paymentMethod: paymentMethod)
        MLURLSessionManager.request(request: RouterRequest.addSEPA(requestObject), success: { data in
            if let ccResponse = MLAddCreditCardResponseBS.parse(data, key: "result") {
                success?(ccResponse)
            }
        }, failure: failiure)
    }
    
    func finishMethodTransaction(paymentMethod: MLPaymentMethod, creditCardResponse: MLAddCreditCardResponseBS, success: Success<String>, failiure: Failiure) {
        
        MLURLSessionManager.request(request: RouterRequest.bsRegisterCreditCard(paymentMethod, creditCardResponse), success: { [unowned self] response in
            
            if let data = response as? Data,
                //BS returns the data encoded in ISOLatin, but xml parser needs the utf8 encoding
                //so the data has to be utf8 encoded
                let utf8Data = data.fromISOLatinToUTF8(),
                let parsedXML = utf8Data.toXMLDictionary(parsingKeys: ["rc", "message"]) {
                print(parsedXML)
                if let rcCode = parsedXML["rc"]{
                    if rcCode == "1343" {
                        self.fetchMethodAlias(paymentMethod: paymentMethod, creditCardResponse: creditCardResponse, success: success, failiure: failiure)
                        //fetch methodID and update pan alias
                    } else if rcCode == "0000" {
                        //all okay
                        success?(creditCardResponse.paymentAlias)
                    } else {
                        print("error")
                    }
                }
                print("success")
            } else {
                print("error")
            }

        }, failure: failiure)
    }
    
    func fetchMethodAlias(paymentMethod: MLPaymentMethod, creditCardResponse: MLAddCreditCardResponseBS, success: Success<String>, failiure: Failiure) {
        
        MLURLSessionManager.request(request: RouterRequest.bsFetchMethodAlias(paymentMethod, creditCardResponse), success: { response in
            print(response)
            
            if let data = response as? Data,
                let utf8Data = data.fromISOLatinToUTF8(),
                let parsedXML = utf8Data.toXMLDictionary(parsingKeys: ["panalias"]),
                let panAlias = parsedXML["panalias"] {
                
                let request = MLUpdatePanaliasRequest(panAlias: panAlias, paymentAlias: creditCardResponse.paymentAlias)
                self.updatePanalias(request: request, success: success, failiure: failiure)
                
            } else {
               print("error")
            }
        }, failure: failiure)
    }
    
    func updatePanalias(request: MLUpdatePanaliasRequest, success: Success<String>, failiure: Failiure) {
        
        MLURLSessionManager.request(request: RouterRequest.updatePanAlias(request), success: { response in
            success?(request.paymentAlias)
        }, failure: failiure)
    }
}
