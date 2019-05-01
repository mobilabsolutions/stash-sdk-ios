//
//  IdempotencyResultUserDefaultsCacher.swift
//  MobilabPaymentCore
//
//  Created by Robert on 30.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

struct IdempotencyResultUserDefaultsCacher<T: Codable, U: Error & Codable>: Cacher {
    typealias Value = IdempotencyResult<T, U>
    typealias Key = String

    private let userDefaults: UserDefaults
    private let queue = DispatchQueue(label: "UserDefaultsCacher-\(UUID().uuidString)")

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var currentDateProvider: DateProviding?

    init(suiteIdentifier: String) {
        let userDefaults = UserDefaults(suiteName: suiteIdentifier)
        self.userDefaults = userDefaults ?? UserDefaults.standard
    }

    func cache(_ value: IdempotencyResult<T, U>, for key: String) {
        self.queue.async {
            if let encodedValueData = try? self.encoder.encode(value) {
                self.userDefaults.set(encodedValueData, forKey: key)
            }
        }
    }

    func getCachedValues() -> [String: IdempotencyResult<T, U>] {
        var values: [String: IdempotencyResult<T, U>]?

        queue.sync {
            values = userDefaults
                .dictionaryRepresentation()
                .compactMapValues({
                    guard let data = $0 as? Data
                    else { return nil }
                    return try? decoder.decode(IdempotencyResult<T, U>.self, from: data)
                }).filter { (_, value) -> Bool in
                    if let provider = self.currentDateProvider {
                        switch value {
                        case let .fulfilled(_, expiry): fallthrough
                        case let .pending(expiry): return provider.currentDate < expiry
                        }
                    }

                    return true
                }
        }

        return values ?? [:]
    }

    func purgeExpiredValues() {
        guard let provider = self.currentDateProvider
        else { return }

        self.queue.async {
            for (key, value) in self.userDefaults.dictionaryRepresentation() {
                guard let data = value as? Data
                else { continue }

                guard let result = try? self.decoder.decode(IdempotencyResult<T, U>.self, from: data)
                else { continue }

                switch result {
                case let .fulfilled(_, expiry): fallthrough
                case let .pending(expiry):
                    if expiry <= provider.currentDate {
                        self.userDefaults.removeObject(forKey: key)
                    }
                }
            }
        }
    }
}
