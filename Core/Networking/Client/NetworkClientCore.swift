//
//  NetworkClientCore.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class NetworkClientCore: NetworkClient {
    
    func createAlias(request: CreateAliasRequest, completion: () -> Void) {

        let router = RouterRequestCore(service: .createAlias(request))
        fetch(with: router, responseType: AliasResponse.self) { (result) in
            
        }
    }
    
    func updateAlias(request:UpdateAliasRequest, completion: () -> Void) {
        
        let router = RouterRequestCore(service: .updateAlias(request))
        self.fetch(with: router, responseType: AliasResponse.self, completion: { (result) in
            
        })
    }

}

