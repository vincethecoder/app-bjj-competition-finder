//
//  CompetitionsLoader+Async.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

extension CompetitionsLoader {
    /// Bridges the completion-based loader to async/await.
    ///
    /// The request starts on the main actor, where the UI owns the loader;
    /// the loader may complete on any thread. The completion is marked
    /// `@Sendable` to make explicit that it isn't tied to the main actor.
    @MainActor
    public func load() async throws -> [Competition] {
        try await withCheckedThrowingContinuation { continuation in
            load { @Sendable result in
                continuation.resume(with: result)
            }
        }
    }
}
