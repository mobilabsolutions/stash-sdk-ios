//
//  NetworkClientCore.swift
//  StashCore
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

class NetworkClientCore: NetworkClient {
    let endpoint: URL

    init(url: URL) {
        self.endpoint = url
    }

    func createAlias(request: CreateAliasRequest, completion: @escaping Completion<CreateAliasResponse>) {
        let router = RouterRequestCore(service: .createAlias(request))
        fetch(with: router, responseType: CreateAliasResponse.self, errorType: StashBackendError.self, completion: completion)
    }

    func updateAlias(request: UpdateAliasRequest, completion: @escaping Completion<AliasResponse>) {
        let router = RouterRequestCore(service: .updateAlias(request))
        fetch(with: router, responseType: AliasResponse.self, errorType: StashBackendError.self, completion: completion)
    }

    func verifyAlias(request: VerifyAliasRequest, completion: @escaping Completion<AliasResponse>) {
        let router = RouterRequestCore(service: .verifyAlias(request))
        fetch(with: router, responseType: AliasResponse.self, errorType: StashBackendError.self, completion: completion)
    }
}
