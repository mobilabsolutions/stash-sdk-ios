//
//  NetworkClientCore.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class NetworkClientCore: NetworkClient {
    
    func addMethod(paymentMethod: MLPaymentMethod, success: SuccessCompletion<String>, failiure: FailureCompletion) {
        
        let requestObject = CreateAliasRequest(pspIdentifier: "", mask: "")
        
        fetch(with: RouterRequest.createAlias(requestObject), decode: { (json) -> CreateAliasRequest? in
            guard let castedJson = json as? CreateAliasRequest else { return  nil }
            return castedJson
        }) { (result) in
            
            switch result {
            case .success(let createAliasResponse):
                
                let provider = PaymentServiceProviderImplementation()
                let standardizedData = StandardizedData(aliasId: "")
                let additionalRegistrationData = AdditionalRegistrationData(data: [:])
                
                let registrationReques = RegistrationRequest(standardizedData: standardizedData, additionalRegistrationData: additionalRegistrationData)
                provider.handleRegistrationRequest(registrationRequest: registrationReques, completion: { (providerResult) in
                    
                    switch providerResult {
                    case .success(let pspAlias):
                        
                        let updateAliasRequest = UpdateAliasRequest(aliasId: "aliasId", billingData: "data")
                        self.fetch(with: RouterRequest.updateAlias("aliasId", updateAliasRequest), decode: { (json) -> UpdateAliasRequest? in
                            guard let castedJson = json as? UpdateAliasRequest else { return  nil }
                            return castedJson
                        }, completion: { (updateAliasResult) in
                            switch result {
                            case .success(let aliasUpdate):
                                success?(aliasUpdate.pspIdentifier)
                            case .failure(let error):
                                failiure?(error)
                            }
                        })
                        
                    case .failure(let error):
                        failiure?(error)
                    }
                    
                })
            case .failure(let error):
                failiure?(error)
            }
        }
        
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

private extension NetworkClientCore {
    
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
