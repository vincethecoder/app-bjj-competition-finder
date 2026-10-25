//
//  CompetitionsLoaderAsyncTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

@MainActor
final class CompetitionsLoaderAsyncTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func load_deliversCompetitionsOnLoaderSuccess() async throws {
        let competitions = uniqueCompetitions()
        let loader = makeSUT()

        let loading = Task { try await loader.load() }
        await loader.waitForLoadRequest()
        loader.completeLoading(with: competitions)

        #expect(try await loading.value == competitions)
    }

    @Test func load_throwsLoaderErrorOnLoaderFailure() async {
        let loader = makeSUT()

        let loading = Task { try await loader.load() }
        await loader.waitForLoadRequest()
        loader.completeLoading(with: anyNSError)

        await #expect(throws: anyNSError) {
            try await loading.value
        }
    }

    @Test func load_deliversCompetitionsWhenLoaderCompletesOnBackgroundThread() async throws {
        let competitions = uniqueCompetitions()
        let loader = makeSUT()

        let loading = Task { try await loader.load() }
        await loader.waitForLoadRequest()
        await Task.detached {
            loader.completeLoading(with: competitions)
        }.value

        #expect(try await loading.value == competitions)
    }

    // MARK: - Helpers

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> CompetitionsLoaderSpy {
        let loader = CompetitionsLoaderSpy()
        leakTracker.track(loader, sourceLocation: sourceLocation)
        return loader
    }
}
