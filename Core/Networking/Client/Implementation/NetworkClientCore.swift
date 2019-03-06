//
//  NetworkClientCore.swift
//  MobilabPaymentCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class NetworkClientCore: NetworkClient {
    func createAlias(completion: @escaping Completion<AliasResponse>) {
        let router = RouterRequestCore(service: .createAlias())
        fetch(with: router, responseType: AliasResponse.self, completion: completion)
    }

    func updateAlias(request: UpdateAliasRequest, completion _: () -> Void) {
        let router = RouterRequestCore(service: .updateAlias(request))
        fetch(with: router, responseType: AliasResponse.self, completion: { _ in

        })
    }
}
