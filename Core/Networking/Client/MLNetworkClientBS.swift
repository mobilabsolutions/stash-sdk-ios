//
//  MLNetworkClientBS.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLNetworkClientBS: MLNetworkClient {
    
    func addMethod(paymentMethod: MLPaymentMethod, success: SuccessCompletion<String>, failiure: FailureCompletion) {
        
        switch paymentMethod.requestData.type {
        
            case MLPaymentMethodType.MLCreditCard:
                
                addCreditCard(paymentMethod: paymentMethod) { (result) in
                    switch result {
                    case .success(let creditCardResponse):
                        self.finishMethodTransaction(paymentMethod: paymentMethod,
                                                     creditCardResponse: creditCardResponse,
                                                     success: success,
                                                     failiure: failiure)
                    case .failure(let error):
                        failiure?(error)
                    }
                }
            
            case MLPaymentMethodType.MLSEPA:
                addSEPA(paymentMethod: paymentMethod) { (result) in
                    switch result {
                    case .success(let creditCardResponse):
                        success?(creditCardResponse.paymentAlias)
                    case .failure(let error):
                        failiure!(error)
                    }
                }
            case MLPaymentMethodType.MLPayPal:
                print("Not implemented")
                return
        }
    }
}

private extension MLNetworkClientBS {
    
    func addCreditCard(paymentMethod: MLPaymentMethod, completion: @escaping Completion<MLAddCreditCardResponseBS>) {
        let requestObject = MLCreditCardRequest(paymentMethod: paymentMethod)
        
        fetch(with: RouterRequest.addCreditCard(requestObject), decode: { json -> MLAddCreditCardResponseBS? in
            guard let castedJson = json as? MLAddCreditCardResponseBS else { return  nil }
            return castedJson
        }, completion: completion)
    }
    
    func addSEPA(paymentMethod: MLPaymentMethod, completion: @escaping Completion<MLAddCreditCardResponseBS>) {
        let requestObject = MLSEPARequest(paymentMethod: paymentMethod)
        fetch(with: RouterRequest.addSEPA(requestObject), decode: { json -> MLAddCreditCardResponseBS? in
            guard let castedJson = json as? MLAddCreditCardResponseBS else { return  nil }
            return castedJson
        }, completion: completion)
    }
    
    func finishMethodTransaction(paymentMethod: MLPaymentMethod, creditCardResponse: MLAddCreditCardResponseBS, success: SuccessCompletion<String>, failiure: FailureCompletion) {
        
//        fetch(request: RouterRequest.bsRegisterCreditCard(paymentMethod, creditCardResponse), success: { [unowned self] response in
//
//            if let data = response as? Data,
//                //BS returns the data encoded in ISOLatin, but xml parser needs the utf8 encoding
//                //so the data has to be utf8 encoded
//                let utf8Data = data.fromISOLatinToUTF8(),
//                let parsedXML = utf8Data.toXMLDictionary(parsingKeys: ["rc", "message"]) {
//                print(parsedXML)
//                if let rcCode = parsedXML["rc"]{
////                    if rcCode == "1343" {
////                        self.fetchMethodAlias(paymentMethod: paymentMethod, creditCardResponse: creditCardResponse, success: success, failiure: failiure)
////                        //fetch methodID and update pan alias
////                    } else if rcCode == "0000" {
////                        //all okay
////                        success?(creditCardResponse.paymentAlias)
////                    } else {
////                        print("error")
////                    }
//                }
//                print("success")
//            } else {
//                print("error")
//            }
//
//        }, failure: failiure)
    }
}
