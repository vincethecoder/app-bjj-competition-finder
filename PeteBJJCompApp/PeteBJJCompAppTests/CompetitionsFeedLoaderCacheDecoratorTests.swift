//
//  CompetitionsFeedLoaderCacheDecoratorTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompApp

final class CompetitionsFeedLoaderCacheDecoratorTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func loadFeed_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let (sut, _) = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    @Test func loadFeed_deliversErrorOnLoaderFailure() {
        let (sut, _) = makeSUT(loaderResult: .failure(anyNSError))

        expect(sut, toCompleteWith: .failure(anyNSError))
    }

    @Test func loadFeed_cachesLoadedFeedWithItsScreenOnLoaderSuccess() {
        let feed = uniqueFeed()
        let (sut, cache) = makeSUT(loaderResult: .success(feed))

        sut.loadFeed { _ in }

        #expect(cache.messages == [.save(feed)])
    }

    @Test func loadFeed_doesNotCacheOnLoaderFailure() {
        let (sut, cache) = makeSUT(loaderResult: .failure(anyNSError))

        sut.loadFeed { _ in }

        #expect(cache.messages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(loaderResult: CompetitionsFeedLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) -> (sut: CompetitionsFeedLoader, cache: CacheSpy) {
        let loader = CompetitionsFeedLoaderStub(result: loaderResult)
        let cache = CacheSpy()
        let sut = CompetitionsFeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        leakTracker.track(loader, sourceLocation: sourceLocation)
        leakTracker.track(cache, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, cache)
    }

    private final class CacheSpy: CompetitionsFeedCache {
        enum Message: Equatable {
            case save(CompetitionsFeed)
        }

        private(set) var messages = [Message]()

        func save(_ feed: CompetitionsFeed, completion: @escaping (CompetitionsFeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}
