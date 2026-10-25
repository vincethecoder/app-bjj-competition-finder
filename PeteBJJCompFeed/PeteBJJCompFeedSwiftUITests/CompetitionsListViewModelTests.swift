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
        #expect(sut.state == .idle)
    }

    @Test func load_showsLoadingIndicatorUntilLoaderCompletes() async {
        let (sut, loader) = makeSUT()

        let loading = Task { await sut.load() }
        await loader.waitForLoadRequest()
        #expect(sut.state == .loading(rows: []))

        loader.completeLoading(with: uniqueCompetitions())
        await loading.value
        #expect(!sut.isLoading)
    }

    @Test func load_keepsRowsOnScreenWhileReloading() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(competitions), on: loader)

        let reloading = Task { await sut.load() }
        await loader.waitForLoadRequest(count: 2)
        #expect(sut.state == .loading(rows: competitions.map(CompetitionRow.init)))

        loader.completeLoading(at: 1)
        await reloading.value
    }

    @Test func load_rendersRowsOnLoaderSuccess() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(competitions), on: loader)

        #expect(sut.state == .loaded(rows: competitions.map(CompetitionRow.init)))
    }

    @Test func load_showsConnectionErrorAndKeepsRowsOnLoaderFailure() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(competitions), on: loader)

        await load(sut, completingWith: .failure(anyNSError), on: loader, at: 1)

        #expect(sut.state == .failed(rows: competitions.map(CompetitionRow.init), message: .feedViewConnectionError))
    }

    @Test func load_clearsErrorOnSuccessfulReload() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .failure(anyNSError), on: loader)

        await load(sut, completingWith: .success(competitions), on: loader, at: 1)

        #expect(sut.state == .loaded(rows: competitions.map(CompetitionRow.init)))
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

    @Test func dismissError_clearsErrorAndKeepsRows() async {
        let competitions = uniqueCompetitions()
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(competitions), on: loader)
        await load(sut, completingWith: .failure(anyNSError), on: loader, at: 1)

        sut.dismissError()

        #expect(sut.state == .loaded(rows: competitions.map(CompetitionRow.init)))
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
