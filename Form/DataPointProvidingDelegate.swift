//
//  DataPointProvidingDelegate.swift
//  StashBSPayone
//
//  Created by Robert on 19.03.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import Foundation

protocol DataPointProvidingDelegate: AnyObject {
    func didUpdate(value: PresentableValueHolding?, for dataPoint: NecessaryData)
}
