//
//  MLUpdatePanaliasRequest.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 25/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import ObjectMapper

class MLUpdatePanaliasRequest: Mappable {
    
    private(set) var panAlias = ""
    private(set) var paymentAlias = ""
    
    init() {
    }
    
    init(panAlias: String, paymentAlias: String) {
        self.panAlias = panAlias
        self.paymentAlias = paymentAlias
    }
    
    required convenience init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        panAlias <- map["panAlias"]
        paymentAlias <- map["paymentAlias"]
    }
}
