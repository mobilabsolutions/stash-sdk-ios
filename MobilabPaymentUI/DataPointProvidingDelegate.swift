//
//  DataPointProvidingDelegate.swift
//  MobilabPaymentBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

public protocol DataPointProvidingDelegate: class {
    func didUpdate(value: String?, for dataPoint: NecessaryData)
}
