//
//  CompetitionsLoaderWithFallbackCompositeTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompApp

final class CompetitionsLoaderWithFallbackCompositeTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func load_deliversPrimaryCompetitionsOnPrimaryLoaderSuccess() {
        let primaryCompetitions = uniqueCompetitions()
        let fallbackCompetitions = uniqueCompetitions()
        let sut = makeSUT(primaryResult: .success(primaryCompetitions), fallbackResult: .success(fallbackCompetitions))

        expect(sut, toCompleteWith: .success(primaryCompetitions))
    }

    @Test func load_deliversFallbackCompetitionsOnPrimaryLoaderFailure() {
        let fallbackCompetitions = uniqueCompetitions()
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .success(fallbackCompetitions))

        expect(sut, toCompleteWith: .success(fallbackCompetitions))
    }

    @Test func load_deliversErrorOnPrimaryAndFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .failure(anyNSError))

        expect(sut, toCompleteWith: .failure(anyNSError))
    }

    // MARK: - Helpers

    private func makeSUT(primaryResult: CompetitionsLoader.Result, fallbackResult: CompetitionsLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) -> CompetitionsLoader {
        let primaryLoader = CompetitionsLoaderStub(result: primaryResult)
        let fallbackLoader = CompetitionsLoaderStub(result: fallbackResult)
        let sut = CompetitionsLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        leakTracker.track(primaryLoader, sourceLocation: sourceLocation)
        leakTracker.track(fallbackLoader, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return sut
    }
}
