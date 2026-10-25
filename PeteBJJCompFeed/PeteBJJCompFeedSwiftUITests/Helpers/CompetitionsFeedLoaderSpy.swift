//
//  CompetitionsFeedLoaderSpy.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

/// Captures load requests so tests decide when, and from which thread, each one completes.
final class CompetitionsFeedLoaderSpy: CompetitionsFeedLoader {
    private var completions = [(CompetitionsFeedLoader.Result) -> Void]()
    private var onLoadRequest: (() -> Void)?

    var loadCallCount: Int {
        completions.count
    }

    func loadFeed(completion: @escaping (CompetitionsFeedLoader.Result) -> Void) {
        completions.append(completion)
        onLoadRequest?()
        onLoadRequest = nil
    }

    /// Suspends until `count` load requests have arrived. Requests reach the spy on the
    /// main actor, so checking and waiting there can't miss one that arrives in between.
    @MainActor
    func waitForLoadRequest(count: Int = 1) async {
        guard loadCallCount < count else { return }

        await withCheckedContinuation { continuation in
            onLoadRequest = { continuation.resume() }
        }
    }

    func completeLoading(with feed: CompetitionsFeed = CompetitionsFeed(competitions: [], screen: nil), at index: Int = 0) {
        completions[index](.success(feed))
    }

    func completeLoading(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }

    /// Completes every request after the first, so a test that fails by making extra
    /// requests reports the failure instead of hanging on them.
    func completeAllPendingLoads() {
        completions.dropFirst().forEach { $0(.success(CompetitionsFeed(competitions: [], screen: nil))) }
    }
}
