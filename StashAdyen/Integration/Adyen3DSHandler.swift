//
//  Adyen3DS2Handler.swift
//  MobilabPaymentAdyen
//
//  Created by Borna Beakovic on 12/08/2019.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Adyen
import Adyen3DS2
import AdyenCard
import Foundation
import StashCore

class Adyen3DSHandler {
    static let sharedInstance = Adyen3DSHandler()

    typealias ThreeDSAuthenticationCompletion = ((Result<ThreeDSResult, StashError>) -> Void)
    private var resultCallback: ThreeDSAuthenticationCompletion?

    private let threeDS2Component: ThreeDS2Component
    private var md: String?

    init() {
        let threeDS2Comp = ThreeDS2Component()
        self.threeDS2Component = threeDS2Comp
        self.threeDS2Component.delegate = self
    }

    func handle(with request: ThreeDSRequest, viewController: UIViewController, resultCallback: @escaping ThreeDSAuthenticationCompletion) {
        self.resultCallback = resultCallback

        do {
            let actionData = try JSONEncoder().encode(request)
            let action = try JSONDecoder().decode(Action.self, from: actionData)
            switch action {
            case .redirect:

                if let paReq = request.paReq, let md = request.md, let acsUrl = request.url {
                    self.md = md
                    DispatchQueue.main.async {
                        let threeDSViewController = ThreeDSWebViewController(paReq: paReq, md: md, acsUrl: acsUrl, termUrl: "https://mobilabsolutions.com")
                        threeDSViewController.delegate = self
                        viewController.navigationController?.pushViewController(threeDSViewController, animated: true)
                    }
                } else {
                    self.resultCallback?(.failure(StashError.network(.responseInvalid)))
                }

            case let .threeDS2Challenge(action):
                self.threeDS2Component.handle(action)
            case let .threeDS2Fingerprint(action):
                self.threeDS2Component.handle(action)
            }
        } catch {
            self.resultCallback?(.failure(StashError.other(.from(error: error))))
        }
    }
}

extension Adyen3DSHandler: ActionComponentDelegate {
    func didProvide(_ data: ActionComponentData, from _: ActionComponent) {
        if let fingerprint = data.details.dictionaryRepresentation["threeds2.fingerprint"] as? String {
            self.resultCallback?(.success(ThreeDSResult(fingerprintResult: fingerprint)))
        } else if let challengeResult = data.details.dictionaryRepresentation["threeds2.challengeResult"] as? String {
            self.resultCallback?(.success(ThreeDSResult(challengeResult: challengeResult)))
        } else {
            self.resultCallback?(.failure(StashError.validation(.other(description: "Adyen 3DS2 fingerprint/challenge data is missing", thirdPartyErrorDetails: nil))))
        }
    }

    func didFail(with error: Error, from _: ActionComponent) {
        self.resultCallback?(.failure(StashError.other(.from(error: error))))
    }
}

extension Adyen3DSHandler: ThreeDSWebViewControllerDelegate {
    func didProvide(paRes: String, md: String) {
        self.resultCallback?(.success(ThreeDSResult(paRes: paRes, md: md)))
    }

    func didFail(with error: Error) {
        self.resultCallback?(.failure(StashError.other(.from(error: error))))
    }
}
