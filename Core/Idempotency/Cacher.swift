//
//  Cacher.swift
//  MobilabPaymentCore
//
//  Created by Robert on 30.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

protocol Cacher {
    associatedtype Key: Hashable
    associatedtype Value: Codable

    func getCachedValues() -> [Key: Value]
    func cache(_ value: Value, for key: Key)
    func purgeExpiredValues()

    var currentDateProvider: DateProviding? { get set }
}
