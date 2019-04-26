//
//  IdempotencyManager.swift
//  MobilabPaymentCore
//
//  Created by Robert on 26.04.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import Foundation

class IdempotencyManager<T: Codable, U: Error> {
    private var idempotencyResults = [String: IdempotencyResult<T, U>]()
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
    func getIdempotencyResultOrStartSession(for key: String, potentiallyEnqueueing completion: @escaping (Result<T, U>) -> Void) -> IdempotencyResult<T, U>? {
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

            idempotencyResults[key] = .pending
            idempotencyResultsLock.signal()

            enqueuedCompletionsForKeyLock.wait()
            enqueuedCompletionsForKey[key] = []
            enqueuedCompletionsForKeyLock.signal()

            lock.signal()

            return nil
        }

        self.idempotencyResultsLock.signal()

        switch result {
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

        return result
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

        idempotencyResultsLock.wait()
        idempotencyResults[key] = idempotencyResult
        idempotencyResultsLock.signal()

        enqueuedCompletionsForKeyLock.wait()
        enqueuedCompletionsForKey[key]?.forEach({ completion in
            self.completionQueue.async {
                completion(result)
            }
        })
        enqueuedCompletionsForKey[key] = nil
        enqueuedCompletionsForKeyLock.signal()

        lock?.signal()
    }
}

enum IdempotencyResult<T: Codable, U: Error> {
    case pending
    case fulfilled(result: Result<T, U>)
}
