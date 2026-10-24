//
//  CompetitionsLoaderCacheDecoratorTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompApp

final class CompetitionsLoaderCacheDecoratorTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func load_deliversCompetitionsOnLoaderSuccess() {
        let competitions = uniqueCompetitions()
        let (sut, _) = makeSUT(loaderResult: .success(competitions))

        expect(sut, toCompleteWith: .success(competitions))
    }

    @Test func load_deliversErrorOnLoaderFailure() {
        let (sut, _) = makeSUT(loaderResult: .failure(anyNSError))

        expect(sut, toCompleteWith: .failure(anyNSError))
    }

    @Test func load_cachesLoadedCompetitionsOnLoaderSuccess() {
        let competitions = uniqueCompetitions()
        let (sut, cache) = makeSUT(loaderResult: .success(competitions))

        sut.load { _ in }

        #expect(cache.messages == [.save(competitions)])
    }

    @Test func load_doesNotCacheOnLoaderFailure() {
        let (sut, cache) = makeSUT(loaderResult: .failure(anyNSError))

        sut.load { _ in }

        #expect(cache.messages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(loaderResult: CompetitionsLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) -> (sut: CompetitionsLoader, cache: CacheSpy) {
        let loader = CompetitionsLoaderStub(result: loaderResult)
        let cache = CacheSpy()
        let sut = CompetitionsLoaderCacheDecorator(decoratee: loader, cache: cache)
        leakTracker.track(loader, sourceLocation: sourceLocation)
        leakTracker.track(cache, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, cache)
    }

    private final class CacheSpy: CompetitionsCache {
        enum Message: Equatable {
            case save([Competition])
        }

        private(set) var messages = [Message]()

        func save(_ competitions: [Competition], completion: @escaping (CompetitionsCache.Result) -> Void) {
            messages.append(.save(competitions))
            completion(.success(()))
        }
    }
}
