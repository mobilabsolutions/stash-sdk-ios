//
//  RegistrationRequest.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public struct RegistrationRequest {
    public var standardizedData: StandardizedData
    public var pspData: Data?
    public var registrationData: Data?

    init(standardizedData: StandardizedData, pspData:Data?, registrationData: Data? = nil) {
        self.standardizedData = standardizedData
        self.pspData = pspData
        self.registrationData = registrationData
    }
}
