//
//  CompetitionsFeedLoaderWithFallbackCompositeTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompApp

final class CompetitionsFeedLoaderWithFallbackCompositeTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func loadFeed_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(primaryFeed))
    }

    @Test func loadFeed_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .success(fallbackFeed))

        expect(sut, toCompleteWith: .success(fallbackFeed))
    }

    @Test func loadFeed_deliversErrorOnPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .failure(anyNSError))

        expect(sut, toCompleteWith: .failure(anyNSError))
    }

    // MARK: - Helpers

    private func makeSUT(primaryResult: CompetitionsFeedLoader.Result, fallbackResult: CompetitionsFeedLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) -> CompetitionsFeedLoader {
        let primaryLoader = CompetitionsFeedLoaderStub(result: primaryResult)
        let fallbackLoader = CompetitionsFeedLoaderStub(result: fallbackResult)
        let sut = CompetitionsFeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        leakTracker.track(primaryLoader, sourceLocation: sourceLocation)
        leakTracker.track(fallbackLoader, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return sut
    }
}
