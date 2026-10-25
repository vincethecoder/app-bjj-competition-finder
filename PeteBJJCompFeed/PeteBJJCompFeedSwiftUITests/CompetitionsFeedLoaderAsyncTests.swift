//
//  CompetitionsFeedLoaderAsyncTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

@MainActor
final class CompetitionsFeedLoaderAsyncTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func loadFeed_deliversFeedOnLoaderSuccess() async throws {
        let feed = makeFeed(screen: makeScreen())
        let loader = makeSUT()

        let loading = Task { try await loader.loadFeed() }
        await loader.waitForLoadRequest()
        loader.completeLoading(with: feed)

        #expect(try await loading.value == feed)
    }

    @Test func loadFeed_throwsLoaderErrorOnLoaderFailure() async {
        let loader = makeSUT()

        let loading = Task { try await loader.loadFeed() }
        await loader.waitForLoadRequest()
        loader.completeLoading(with: anyNSError)

        await #expect(throws: anyNSError) {
            try await loading.value
        }
    }

    @Test func loadFeed_deliversFeedWhenLoaderCompletesOnBackgroundThread() async throws {
        let feed = makeFeed(screen: makeScreen())
        let loader = makeSUT()

        let loading = Task { try await loader.loadFeed() }
        await loader.waitForLoadRequest()
        await Task.detached {
            loader.completeLoading(with: feed)
        }.value

        #expect(try await loading.value == feed)
    }

    // MARK: - Helpers

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> CompetitionsFeedLoaderSpy {
        let loader = CompetitionsFeedLoaderSpy()
        leakTracker.track(loader, sourceLocation: sourceLocation)
        return loader
    }
}
