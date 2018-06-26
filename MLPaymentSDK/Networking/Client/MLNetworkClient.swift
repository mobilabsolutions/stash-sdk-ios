//
//  MLNetworkClient.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

class MLNetworkClient: NSObject {
    
    typealias Success<T> = MLURLSessionManager.SuccessCompletion<T>
    typealias Failiure = MLURLSessionManager.FailureCompletion

    var configuration: MLConfiguration!
    
    init(configuration: MLConfiguration) {
        self.configuration = configuration
    }
    
    //test these down here:
    func togetherPay() {
        print("together pay yuhuuuu")
    }
    
    func bsPay() {
        print("should be overriden")
    }
    
    func hcPay() {
        print("should be overriden")
    }
    
    func addMethod(paymentMethod: MLPaymentMethod,
                   success: MLURLSessionManager.SuccessCompletion<String>,
                   failiure: MLURLSessionManager.FailureCompletion) {
        print("should be overriden")
    }
}

//MARK: Shared methods
extension MLNetworkClient {
    
    
}
