//
//  MemoryLeakTracker.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing

/// Swift Testing has no `addTeardownBlock`, so suites own a tracker and call
/// `verify()` from `deinit`, which runs after each test's locals are released.
final class MemoryLeakTracker {
    private var checks: [() -> Void] = []

    func track(_ instance: AnyObject, sourceLocation: SourceLocation = #_sourceLocation) {
        checks.append { [weak instance] in
            #expect(instance == nil, "Instance should have been deallocated. Potential memory leak.", sourceLocation: sourceLocation)
        }
    }

    func verify() {
        checks.forEach { $0() }
    }
}
