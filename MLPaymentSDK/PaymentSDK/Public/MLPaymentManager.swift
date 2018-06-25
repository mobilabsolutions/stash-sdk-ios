//
//  MLPaymentManager.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 15/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import UIKit

@objc protocol MLPaymentManagerProtocol: class {
    @objc func creditCardPaymnetCompleted(transactionID: String?, error: MLError?)
    @objc func creditCardPaymnetWithAliasCompleted(transactionID: String?, error: MLError?)
    @objc func SEPAPaymnetWithAliasCompleted(transactionID: String?, error: MLError?)
}

class MLPaymentManager: NSObject {
    
    weak var delegate: MLPaymentManagerProtocol!
    
    init(delegate: MLPaymentManagerProtocol) {
        self.delegate = delegate
    }
    
    func executeCreditCardPaymnet(creditCardData: MLCreditCardData, billingData: MLBillingData, paymentData: MLPaymentData) {
        
    }
    
    func executeCreditCardPaymentWithAlias(creditCardAlias: String, paymentData: MLPaymentData) {
        
    }
    
    func executeSEPAPaymnetWithAlias(sepaAlias: String, paymentData: MLPaymentData) {
        
    }
}
