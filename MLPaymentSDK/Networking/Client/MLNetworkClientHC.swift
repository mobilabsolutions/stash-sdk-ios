//
//  MLNetworkingClientHC.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

class MLNetworkClientHC: MLNetworkClient {

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
            break
            
        case MLPaymentMethodType.MLPayPal:
            print("Not implemented")
            return
        }
    }
}

private extension MLNetworkClientHC {
    func addCreditCard(paymentMethod: MLPaymentMethod, success: Success<MLAddCreditCardResponseHC>, failiure: Failiure) {
        let requestObject = MLCreditCardRequest(paymentMethod: paymentMethod)
        MLURLSessionManager.request(request: RouterRequest.addCreditCardBS(requestObject), success: { data in
            if let ccResponse = MLAddCreditCardResponseHC.parse(data, key: "result") {
                success?(ccResponse)
            }
        }, failure: failiure)
    }
    
    func finishMethodTransaction(paymentMethod: MLPaymentMethod, creditCardResponse: MLAddCreditCardResponseHC, success: Success<String>, failiure: Failiure) {

        MLURLSessionManager.request(request: RouterRequest.hcRegisterCreditCard(paymentMethod, creditCardResponse), success: { response in

            if let data = response as? Data {
                if let parsedXML = data.toXMLDictionary(parsingKeys: ["status", "message", "code"]) {
                    print(parsedXML)
                    if let status = parsedXML["status"]{
                        if status == "approved" {
                            success?(creditCardResponse.paymentAlias)
                            return
                        } else {
                            let message = parsedXML["message"] ?? ""
                            let code = Int(parsedXML["code"] ?? "") ?? -1
                            let error = MLError(title: message, description: message, code: code)
                            failiure?(error)
                            return
                        }
                    }
                }
            }
            print("error")
        }, failure: failiure)
        
    }
}
