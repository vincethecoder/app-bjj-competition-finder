//
//  CompetitionsGridViewModelTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

@MainActor
final class CompetitionsGridViewModelTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func init_doesNotRequestLoad() {
        let (sut, loader) = makeSUT()

        #expect(loader.loadCallCount == 0)
        #expect(sut.state == .idle)
        #expect(sut.visibleSections.isEmpty)
    }

    @Test func load_showsLoadingIndicatorUntilLoaderCompletes() async {
        let (sut, loader) = makeSUT()

        let loading = Task { await sut.load() }
        await loader.waitForLoadRequest()
        #expect(sut.state == .loading(screen: nil))

        loader.completeLoading(with: makeFeed(screen: makeScreen()))
        await loading.value
        #expect(!sut.isLoading)
    }

    @Test func load_keepsScreenOnDisplayWhileReloading() async throws {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)
        let loadedScreen = try #require(sut.screen)

        let reloading = Task { await sut.load() }
        await loader.waitForLoadRequest(count: 2)
        #expect(sut.state == .loading(screen: loadedScreen))
        #expect(sut.visibleSections.map(\.id) == ["2026-05", "2026-06"])

        loader.completeLoading(at: 1)
        await reloading.value
    }

    @Test func load_rendersServerSectionsInServerOrderOnLoaderSuccess() async {
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)

        #expect(sut.screen?.title == "Championships")
        #expect(sut.visibleSections.map(\.id) == ["2026-05", "2026-06"])
        #expect(sut.visibleSections.map { $0.cards.map(\.id) } == [["worlds", "nogi-worlds"], ["brasileiro"]])
        #expect(sut.state == .loaded(screen: map(makeFeed(screen: makeScreen()))))
    }

    @Test func load_showsConnectionErrorAndKeepsScreenOnLoaderFailure() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)
        let loadedScreen = sut.screen

        await load(sut, completingWith: .failure(anyNSError), on: loader, at: 1)

        #expect(sut.state == .failed(screen: loadedScreen, message: .feedViewConnectionError))
        #expect(sut.visibleSections.map(\.id) == ["2026-05", "2026-06"])
    }

    @Test func load_showsCachedScreenWithConnectionErrorWhenFeedComesFromCache() async {
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen(), cachedAt: .now)), on: loader)

        #expect(sut.state == .failed(screen: map(makeFeed(screen: makeScreen())), message: .feedViewConnectionError))
        #expect(sut.visibleSections.map(\.id) == ["2026-05", "2026-06"])
    }

    @Test func load_clearsErrorOnSuccessfulReload() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .failure(anyNSError), on: loader)

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader, at: 1)

        #expect(sut.state == .loaded(screen: map(makeFeed(screen: makeScreen()))))
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

    @Test func dismissError_keepsScreenOnDisplay() async throws {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)
        let loadedScreen = try #require(sut.screen)
        await load(sut, completingWith: .failure(anyNSError), on: loader, at: 1)

        sut.dismissError()

        #expect(sut.state == .loaded(screen: loadedScreen))
    }

    @Test func dismissError_returnsToIdleWithNoScreenToShow() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .failure(anyNSError), on: loader)

        sut.dismissError()

        #expect(sut.state == .idle)
    }

    @Test func load_buildsSectionsFromCompetitionsWhenScreenIsMissing() async {
        let may = uniqueCompetition(id: "may", startDate: date(2026, 5, 30), endDate: date(2026, 6, 2))
        let june = uniqueCompetition(id: "june", startDate: date(2026, 6, 12), endDate: date(2026, 6, 15))
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(makeFeed(competitions: [june, may], screen: nil)), on: loader)

        #expect(sut.visibleSections.map(\.title) == ["May 2026", "June 2026"])
        #expect(sut.visibleSections.map { $0.cards.map(\.id) } == [["may"], ["june"]])
        #expect(sut.screen?.filters.map(\.id) == ["all", "gi", "nogi", "open"])
    }

    @Test func load_selectsFirstFilter() async {
        let (sut, loader) = makeSUT()

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)

        #expect(sut.selectedFilterID == "all")
    }

    @Test func selectFilter_hidesCardsTheFilterDoesNotMatch() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)

        sut.selectFilter("nogi")

        #expect(sut.selectedFilterID == "nogi")
        #expect(sut.visibleSections.map { $0.cards.map(\.id) } == [["nogi-worlds"]])

        sut.selectFilter("open")

        #expect(sut.visibleSections.map { $0.cards.map(\.id) } == [["worlds"], ["brasileiro"]])
    }

    @Test func selectFilter_ignoresFiltersTheScreenDoesNotOffer() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)

        sut.selectFilter("black-belt")

        #expect(sut.selectedFilterID == "all")
        #expect(sut.visibleSections.flatMap(\.cards).count == 3)
    }

    @Test func selectFilter_reportsFilteredToNothingOnlyWhileTheFilterHidesEveryEvent() async {
        let seminarFilter = CompetitionsScreen.Filter(id: "seminar", title: "Seminars", criterion: .type("seminar"))
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen(filters: [allFilter, seminarFilter]))), on: loader)
        #expect(!sut.isFilteredToNothing)

        sut.selectFilter("seminar")

        #expect(sut.visibleSections.isEmpty)
        #expect(sut.isFilteredToNothing)

        sut.selectFilter("all")

        #expect(!sut.isFilteredToNothing)
    }

    @Test func load_doesNotReportFilteredToNothingForScreenWithoutEvents() async {
        let (sut, loader) = makeSUT()
        #expect(!sut.isFilteredToNothing)

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen(sections: []))), on: loader)

        #expect(sut.visibleSections.isEmpty)
        #expect(!sut.isFilteredToNothing)
    }

    @Test func load_keepsSelectedFilterWhenReloadedScreenStillOffersIt() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)
        sut.selectFilter("nogi")

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader, at: 1)

        #expect(sut.selectedFilterID == "nogi")
        #expect(sut.visibleSections.map { $0.cards.map(\.id) } == [["nogi-worlds"]])
    }

    @Test func load_selectsFirstFilterWhenReloadedScreenNoLongerOffersSelection() async {
        let (sut, loader) = makeSUT()
        await load(sut, completingWith: .success(makeFeed(screen: makeScreen())), on: loader)
        sut.selectFilter("nogi")

        await load(sut, completingWith: .success(makeFeed(screen: makeScreen(filters: [giFilter, allFilter]))), on: loader, at: 1)

        #expect(sut.selectedFilterID == "gi")
    }

    // MARK: - Helpers

    private func makeSUT(sourceLocation: SourceLocation = #_sourceLocation) -> (sut: CompetitionsGridViewModel, loader: CompetitionsFeedLoaderSpy) {
        let loader = CompetitionsFeedLoaderSpy()
        let sut = CompetitionsGridViewModel(loader: loader, locale: testLocale, calendar: testCalendar)
        leakTracker.track(loader, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, loader)
    }

    private func map(_ feed: CompetitionsFeed) -> PosterScreen {
        PosterScreenMapper.map(feed, locale: testLocale, calendar: testCalendar)
    }

    private func load(_ sut: CompetitionsGridViewModel, completingWith result: CompetitionsFeedLoader.Result, on loader: CompetitionsFeedLoaderSpy, at index: Int = 0) async {
        let loading = Task { await sut.load() }
        await loader.waitForLoadRequest(count: index + 1)

        switch result {
        case let .success(feed):
            loader.completeLoading(with: feed, at: index)
        case let .failure(error):
            loader.completeLoading(with: error, at: index)
        }

        await loading.value
    }
}
