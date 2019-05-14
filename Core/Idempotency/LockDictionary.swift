//
//  ThreadSafeDictionary.swift
//  MobilabPaymentCore
//
//  Created by Robert on 26.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class LockDictionary<K: Hashable> {
    private var underlyingDictionary: [K: DispatchSemaphore] = [:]
    private let queue = DispatchQueue(label: "LockDictionary-\(UUID().uuidString)", attributes: .concurrent)

    func withLock<T>(for key: K, do completion: @escaping () -> T) -> T {
        var result: T!
        queue.sync {
            self.underlyingDictionary[key]?.wait()
            result = completion()
            self.underlyingDictionary[key]?.signal()
        }

        return result
    }

    func setAndUseLock<T>(for key: K, do completion: @escaping () -> T) -> T {
        var result: T!

        queue.sync(flags: .barrier) {
            self.underlyingDictionary[key] = DispatchSemaphore(value: 1)
            self.underlyingDictionary[key]?.wait()
            result = completion()
            self.underlyingDictionary[key]?.signal()
        }

        return result
    }
}
