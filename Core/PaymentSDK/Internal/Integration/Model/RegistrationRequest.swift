//
//  RegistrationRequest.swift
//  MLPaymentSDK
//
//  Created by Borna Beakovic on 27/02/2019.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation


public struct RegistrationRequest {
    
    var standardizedData: StandardizedData
    var additionalRegistrationData: AdditionalRegistrationData
    
    init(standardizedData: StandardizedData, additionalRegistrationData: AdditionalRegistrationData) {
        self.standardizedData = standardizedData
        self.additionalRegistrationData = additionalRegistrationData
    }
}
