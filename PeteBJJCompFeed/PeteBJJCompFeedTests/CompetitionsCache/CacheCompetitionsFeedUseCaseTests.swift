//
//  CacheCompetitionsFeedUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed

final class CacheCompetitionsFeedUseCaseTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func save_insertsCompetitionsWithEncodedScreenAfterDeletingCache() throws {
        let timestamp = Date.now
        let competition = makeFeedCompetition()
        let screen = makeScreen(cardID: competition.id)
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(CompetitionsFeed(competitions: [competition], screen: screen)) { _ in }
        store.completeDeletionSuccessfully()

        let insertedScreen = try #require(insertedScreenData(in: store))
        #expect(try JSONDecoder().decode(CompetitionsScreen.self, from: insertedScreen) == screen)
        #expect(store.receivedMessages == [.deleteCachedCompetitions, .insert([competition.local], insertedScreen, timestamp)])
    }

    @Test func save_insertsNoScreenForFeedWithoutScreen() {
        let timestamp = Date.now
        let competition = makeFeedCompetition()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(CompetitionsFeed(competitions: [competition], screen: nil)) { _ in }
        store.completeDeletionSuccessfully()

        #expect(store.receivedMessages == [.deleteCachedCompetitions, .insert([competition.local], nil, timestamp)])
    }

    @Test func loadFeed_deliversCachedCompetitionsAndScreenOnNonExpiredCache() throws {
        let now = Date.now
        let competition = makeFeedCompetition()
        let screen = makeScreen(cardID: competition.id)
        let (sut, store) = makeSUT(currentDate: { now })

        let feed = try loadFeed(from: sut) {
            store.completeRetrieval(with: [competition.local], screen: try? JSONEncoder().encode(screen), timestamp: now)
        }.get()

        #expect(feed == CompetitionsFeed(competitions: [competition], screen: screen, cachedAt: now))
    }

    @Test func loadFeed_deliversCompetitionsWithoutScreenWhenCachedScreenIsCorrupted() throws {
        let now = Date.now
        let competition = makeFeedCompetition()
        let (sut, store) = makeSUT(currentDate: { now })

        let feed = try loadFeed(from: sut) {
            store.completeRetrieval(with: [competition.local], screen: Data("corrupted".utf8), timestamp: now)
        }.get()

        #expect(feed == CompetitionsFeed(competitions: [competition], screen: nil, cachedAt: now))
    }

    @Test func loadFeed_deliversEmptyFeedOnExpiredCacheEvenWithScreen() throws {
        let now = Date.now
        let (sut, store) = makeSUT(currentDate: { now })

        let feed = try loadFeed(from: sut) {
            store.completeRetrieval(with: [makeFeedCompetition().local], screen: try? JSONEncoder().encode(makeScreen()), timestamp: now.minusCompetitionsCacheMaxAge)
        }.get()

        #expect(feed == CompetitionsFeed(competitions: [], screen: nil))
    }

    @Test func loadFeed_failsOnRetrievalError() throws {
        let (sut, store) = makeSUT()

        let result = try loadFeed(from: sut) { store.completeRetrieval(with: anyNSError) }

        #expect(throws: anyNSError) { try result.get() }
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, sourceLocation: SourceLocation = #_sourceLocation) -> (sut: LocalCompetitionsLoader, store: CompetitionsStoreSpy) {
        let store = CompetitionsStoreSpy()
        let sut = LocalCompetitionsLoader(store: store, currentDate: currentDate)
        leakTracker.track(store, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, store)
    }

    private func loadFeed(from sut: LocalCompetitionsLoader, when action: () -> Void, sourceLocation: SourceLocation = #_sourceLocation) throws -> CompetitionsFeedLoader.Result {
        var receivedResult: CompetitionsFeedLoader.Result?
        sut.loadFeed { receivedResult = $0 }

        action()

        return try #require(receivedResult, "Expected loadFeed to complete", sourceLocation: sourceLocation)
    }

    private func insertedScreenData(in store: CompetitionsStoreSpy) -> Data? {
        store.receivedMessages.lazy.compactMap { message -> Data? in
            if case let .insert(_, screen, _) = message { screen } else { nil }
        }.first
    }
}
