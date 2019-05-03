//
//  IdempotencyManager.swift
//  MobilabPaymentCore
//
//  Created by Robert on 26.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class IdempotencyManager<T: Codable, U: Error & Codable & IdempotencyApplicationFailureProviding, C: Cacher>
    where C.Key == String, C.Value == IdempotencyResultContainer<T, U> {
    private let cacher: C
    private let dateProvider: DateProviding

    init(cacher: C, dateProvider: DateProviding = DefaultDateProvider()) {
        self.cacher = cacher
        self.dateProvider = dateProvider

        cacher.purgeExpiredValues()
        self.idempotencyResults = cacher.getCachedValues()
            .filter {
                $0.value.expiry > dateProvider.currentDate
            }
            .mapValues { value in
                if case .pending = value.idempotencyResult {
                    let error = U.createErrorForPendingRequestSinceLastStart()
                    return IdempotencyResultContainer(idempotencyResult: .fulfilled(result: Result<T, U>.failure(error)),
                                                      expiry: value.expiry,
                                                      typeIdentifier: value.typeIdentifier)
                }

                return value
            }
    }

    private var idempotencyResults = [String: IdempotencyResultContainer<T, U>]()
    private let idempotencyResultsLock = DispatchSemaphore(value: 1)
    /// Completions that should be called once a _started_ idempotency mechanism for a key completes.
    /// This is used in the cases where another request is started while a given request is running.
    private var enqueuedCompletionsForKey = [String: [(Result<T, U>) -> Void]]()
    private let enqueuedCompletionsForKeyLock = DispatchSemaphore(value: 1)
    /// Mutex for access to a given idempotency key's resources. Used so that only one thread at a time can
    /// enqueue / read from the completions and write results.
    private var locks = [String: DispatchSemaphore]()
    private let locksLock = DispatchSemaphore(value: 1)

    private let completionQueue = DispatchQueue(label: "IdempotencyCompletionQueue")

    /// Either get a (done or pending) result for the idempotency key or (if such result does not exist) start a new idempotency session
    ///
    /// - Parameters:
    ///   - key: The idempotency key that the result should be fetched or session should be started for
    ///   - completion: The completion to enqueue to an internal list of completions for the result for the given idempotency key if it is pending
    /// - Returns: An idempotency result if one could be found or nil if none is present and a new session has been started
    func getIdempotencyResultOrStartSession(for key: String,
                                            potentiallyEnqueueing completion: @escaping (Result<T, U>) -> Void,
                                            typeIdentifier: String) throws -> IdempotencyResult<T, U>? {
        self.locksLock.wait()
        let lock = locks[key]
        locksLock.signal()
        lock?.wait()

        idempotencyResultsLock.wait()
        guard let result = idempotencyResults[key]
        else {
            // If there is no result for the key, we know that there will also not be a lock, so we don't need to signal it.
            // Instead we want to start a new session here.
            self.locksLock.wait()
            let lock = DispatchSemaphore(value: 1)
            locks[key] = lock
            locksLock.signal()
            lock.wait()

            let newIdempotencyResult = IdempotencyResultContainer(idempotencyResult: IdempotencyResult<T, U>.pending,
                                                                  expiry: dateProvider.expiryDate,
                                                                  typeIdentifier: typeIdentifier)
            idempotencyResults[key] = newIdempotencyResult
            idempotencyResultsLock.signal()

            enqueuedCompletionsForKeyLock.wait()
            enqueuedCompletionsForKey[key] = []
            enqueuedCompletionsForKeyLock.signal()

            lock.signal()

            cacher.cache(newIdempotencyResult, for: key)

            return nil
        }

        self.idempotencyResultsLock.signal()

        switch result.idempotencyResult {
        // If the result is already fulfilled, alas there is no currently running request for this idempotency key
        // we should just return the result directly and free the lock.
        case .fulfilled:
            break
        case .pending:
            // The result is not currently fulfilled, so there is a running request. We will enqueue the given completion
            // to the waiting completions for this key. It will be called when the running request is finished.
            self.enqueuedCompletionsForKeyLock.wait()
            self.enqueuedCompletionsForKey[key]?.append(completion)
            self.enqueuedCompletionsForKeyLock.signal()
        }

        // Free the lock so that another thread can access and modify the data for this key. This will allow the
        // currently running request to finish up.
        lock?.signal()

        guard result.typeIdentifier == typeIdentifier
        else { throw MobilabPaymentError.other(GenericErrorDetails(description: "Idempotency key used for different payment method types. That's illegal.")) }

        return result.idempotencyResult
    }

    /// Set a result for a given idempotency key and thereby end the current request for that key
    ///
    /// - Parameters:
    ///   - result: The result that should be set for the key
    ///   - key: The current idempotency key that should be used
    func setAndEndIdempotencyHandling(result: Result<T, U>, for key: String) {
        self.locksLock.wait()
        let lock = locks[key]
        locksLock.signal()
        lock?.wait()

        let idempotencyResult = IdempotencyResult.fulfilled(result: result)
        let idempotencyResultContainer: IdempotencyResultContainer<T, U>

        idempotencyResultsLock.wait()

        // Get the previously saved result
        if let oldResult = idempotencyResults[key] {
            idempotencyResultContainer = IdempotencyResultContainer(idempotencyResult: idempotencyResult,
                                                                    expiry: oldResult.expiry,
                                                                    typeIdentifier: oldResult.typeIdentifier)
            self.idempotencyResults[key] = idempotencyResultContainer
        } else {
            self.idempotencyResultsLock.signal()
            return
        }

        self.idempotencyResultsLock.signal()

        self.enqueuedCompletionsForKeyLock.wait()
        self.enqueuedCompletionsForKey[key]?.forEach({ completion in
            self.completionQueue.async {
                completion(result)
            }
        })
        self.enqueuedCompletionsForKey[key] = nil
        self.enqueuedCompletionsForKeyLock.signal()

        lock?.signal()

        self.cacher.cache(idempotencyResultContainer, for: key)
    }
}

struct IdempotencyResultContainer<T: Codable, U: Error & Codable>: Codable {
    let idempotencyResult: IdempotencyResult<T, U>
    let expiry: Date
    let typeIdentifier: String
}

enum IdempotencyResult<T: Codable, U: Error & Codable>: Codable {
    case pending
    case fulfilled(result: Result<T, U>)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: IdempotencyResultKey.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "PENDING":
            self = .pending
        case "FULFILLED":
            let resultContaining = try container.decode(ResultContaining<T, U>.self, forKey: .result)
            self = .fulfilled(result: resultContaining.result)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                                                   debugDescription: "Could not decode IdempotencyResult for unknown type \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: IdempotencyResultKey.self)

        switch self {
        case let .fulfilled(result):
            try container.encode("FULFILLED", forKey: .type)
            try container.encode(ResultContaining(result: result), forKey: .result)
        case .pending:
            try container.encode("PENDING", forKey: .type)
        }
    }

    private enum IdempotencyResultKey: CodingKey {
        case type
        case result
        case expiryDate
    }
}

private struct ResultContaining<T: Codable, U: Codable & Error>: Codable {
    let result: Result<T, U>

    init(result: Result<T, U>) {
        self.result = result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ResultContainingKey.self)
        let isSuccess = try container.decode(Bool.self, forKey: .isSuccess)

        if isSuccess {
            self.result = .success(try container.decode(T.self, forKey: .result))
        } else {
            self.result = .failure(try container.decode(U.self, forKey: .result))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ResultContainingKey.self)

        switch self.result {
        case let .failure(error):
            try container.encode(false, forKey: .isSuccess)
            try container.encode(error, forKey: .result)
        case let .success(value):
            try container.encode(true, forKey: .isSuccess)
            try container.encode(value, forKey: .result)
        }
    }

    private enum ResultContainingKey: CodingKey {
        case isSuccess
        case result
    }
}

protocol IdempotencyApplicationFailureProviding {
    static func createErrorForPendingRequestSinceLastStart() -> Self
}

protocol DateProviding {
    var currentDate: Date { get }
    var expiryDate: Date { get }
}

private struct DefaultDateProvider: DateProviding {
    var currentDate: Date {
        return Date()
    }

    var expiryDate: Date {
        return Date().addingTimeInterval(24 * 60 * 60)
    }
}
