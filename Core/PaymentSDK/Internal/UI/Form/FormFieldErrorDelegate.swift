//
//  FormFieldErrorDelegate.swift
//  MobilabPaymentCore
//
//  Created by Robert on 21.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

protocol FormFieldErrorDelegate: class {
    func setError(description: String?, forDataPoint dataPoint: NecessaryData)
}
