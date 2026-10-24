//
//  CompetitionsListViewModelTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

@MainActor
final class CompetitionsListViewModelTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func init_doesNotRequestLoad() {
        let (sut, loader) = makeSUT()

        #expect(loader.loadCallCount == 0)
        #expect(sut.rows.isEmpty)
        #expect(!sut.isLoading)
        #expect(sut.errorMessage == nil)
    }

    @Test func load_showsLoadingIndicatorUntilLoaderCompletes() async {
        let (sut, loader) = makeSUT()

        let loading = Task { await sut.load() }
        await loader.waitForLoadRequest()
        #expect(sut.isLoading)

        loader.completeLoading(with: uniqueCompetitions())
        await loading.value
        #expect(!sut.isLoading)
    }

    @Test func load_rendersRowsOnLoaderSuccess() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(competitions), on: loader)

        #expect(sut.rows == competitions.map(CompetitionRow.init))
        #expect(sut.errorMessage == nil)
    }

    @Test func load_showsConnectionErrorAndKeepsRowsOnLoaderFailure() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(competitions), on: loader)

        await load(sut, completingWith: .failure(anyNSError), on: loader, at: 1)

        #expect(sut.errorMessage == FeedStrings.connectionError)
        #expect(sut.rows == competitions.map(CompetitionRow.init))
        #expect(!sut.isLoading)
    }

    @Test func load_clearsErrorOnSuccessfulReload() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .failure(anyNSError), on: loader)

        await load(sut, completingWith: .success(uniqueCompetitions()), on: loader, at: 1)

        #expect(sut.errorMessage == nil)
    }

    @Test func load_doesNotRequestAgainWhileLoading() async {
        let (sut, loader) = makeSUT()
        let firstLoad = Task { await sut.load() }
        await loader.waitForLoadRequest()

        // Main-actor tasks start in order, so this load runs before the first one finishes.
        let secondLoad = Task { await sut.load() }
        loader.completeLoading()
        await firstLoad.value

        #expect(loader.loadCallCount == 1)

        loader.completeAllPendingLoads()
        await secondLoad.value
    }

    @Test func dismissError_clearsErrorMessage() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .failure(anyNSError), on: loader)

        sut.dismissError()

        #expect(sut.errorMessage == nil)
    }

    // MARK: - Helpers

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> (sut: CompetitionsListViewModel, loader: CompetitionsLoaderSpy) {
        let loader = CompetitionsLoaderSpy()
        let sut = CompetitionsListViewModel(loader: loader)
        leakTracker.track(loader, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, loader)
    }

    private func load(_ sut: CompetitionsListViewModel, completingWith result: CompetitionsLoader.Result, on loader: CompetitionsLoaderSpy, at index: Int = 0) async {
        let loading = Task { await sut.load() }
        await loader.waitForLoadRequest(count: index + 1)

        switch result {
        case let .success(competitions):
            loader.completeLoading(with: competitions, at: index)
        case let .failure(error):
            loader.completeLoading(with: error, at: index)
        }

        await loading.value
    }
}
