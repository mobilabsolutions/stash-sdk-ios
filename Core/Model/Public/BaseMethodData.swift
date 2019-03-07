//
//  MLRegisterAccountData.swift
//  MLPaymentSDK
//
//  Created by Mirza Zenunovic on 20/06/2018.
//  Copyright © 2018 MobiLab. All rights reserved.
//

import Foundation

protocol BaseMethodData   {
    
    func toBSPayoneData() -> Data?
    
}
