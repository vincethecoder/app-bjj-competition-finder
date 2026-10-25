//
//  CompetitionsAcceptanceTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import SwiftUI
import UIKit
import PeteBJJCompFeed
import PeteBJJCompFeedSwiftUI
@testable import PeteBJJCompApp

@MainActor
struct CompetitionsAcceptanceTests {

    @Test func onLaunch_displaysServerScreenWhenCustomerHasConnectivity() async throws {
        let feed = try await launch(httpClient: .online(response), store: .empty)

        #expect(feed.screen?.title == "Championships")
        #expect(feed.visibleSections.map(\.title) == ["May 2024"])
        #expect(feed.visibleSections.flatMap(\.cards).map(\.id) == ["competition-1", "competition-2"])
        #expect(feed.errorMessage == nil)
    }

    @Test func onLaunch_buildsScreenFromCompetitionsWhenServerSendsNoScreen() async throws {
        let feed = try await launch(httpClient: .online(competitionsOnlyResponse), store: .empty)

        #expect(feed.visibleSections.count == 1)
        #expect(feed.visibleSections.flatMap(\.cards).map(\.id) == ["competition-1", "competition-2"])
        #expect(feed.screen?.filters.isEmpty == false)
    }

    @Test func onLaunch_displaysCachedServerScreenWithConnectionErrorWhenCustomerHasNoConnectivity() async throws {
        let sharedStore = InMemoryCompetitionsStore.empty
        _ = try await launch(httpClient: .online(response), store: sharedStore)

        let offlineFeed = try await launch(httpClient: .offline, store: sharedStore)

        #expect(offlineFeed.screen?.title == "Championships")
        #expect(offlineFeed.visibleSections.flatMap(\.cards).map(\.id) == ["competition-1", "competition-2"])
        #expect(offlineFeed.errorMessage != nil)
    }

    @Test func onLaunch_displaysEmptyCompetitionsWhenCustomerHasNoConnectivityAndEmptyCache() async throws {
        let feed = try await launch(httpClient: .offline, store: .empty)

        #expect(feed.visibleSections.isEmpty)
    }

    @Test func onEnteringBackground_deletesExpiredCompetitionsCache() throws {
        let store = InMemoryCompetitionsStore.withExpiredCache

        try enterBackground(with: store)

        #expect(store.cache == nil)
    }

    @Test func onEnteringBackground_keepsNonExpiredCompetitionsCache() throws {
        let store = InMemoryCompetitionsStore.withNonExpiredCache

        try enterBackground(with: store)

        #expect(store.cache != nil)
    }

    // MARK: - Helpers

    /// Launches the composed app and loads the feed through its view model, the
    /// same call the feed view makes in `.task` when it appears.
    private func launch(httpClient: HTTPClientStub, store: InMemoryCompetitionsStore) async throws -> CompetitionsGridViewModel {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let feed = try #require(sut.window?.rootViewController as? UIHostingController<CompetitionsGridView>)
        #expect(sut.window?.isHidden == false, "Expected configureWindow to make the window visible")

        await feed.rootView.viewModel.load()
        return feed.rootView.viewModel
    }

    private func enterBackground(with store: InMemoryCompetitionsStore) throws {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        let scene = try #require(UIApplication.shared.connectedScenes.first)
        sut.sceneWillResignActive(scene)
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeCompetitionsData(), response)
    }

    private func competitionsOnlyResponse(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeCompetitionsData(includingScreen: false), response)
    }

    private func makeCompetitionsData(includingScreen: Bool = true) -> Data {
        Data("""
        {
            "competitions": [
                \(makeCompetitionJSON(id: "competition-1")),
                \(makeCompetitionJSON(id: "competition-2"))
            ]\(includingScreen ? ", \"screen\": \(makeScreenJSON())" : "")
        }
        """.utf8)
    }

    private func makeScreenJSON() -> String {
        """
        {
            "layout": "posterGrid",
            "title": "Championships",
            "filters": [{ "id": "all", "title": "All", "field": "none" }],
            "sections": [{
                "id": "2024-05",
                "title": "May 2024",
                "cards": [\(makeCardJSON(id: "competition-1")), \(makeCardJSON(id: "competition-2"))]
            }]
        }
        """
    }

    private func makeCardJSON(id: String) -> String {
        """
        {
            "id": "\(id)",
            "name": "World IBJJF Jiu-Jitsu Championship",
            "dateLabel": "May 30 – Jun 2",
            "locationLabel": "Long Beach, USA",
            "eventLink": "https://ibjjf.com/events/world-championship",
            "badges": [{ "id": "gi", "title": "Gi", "token": "type" }]
        }
        """
    }

    private func makeCompetitionJSON(id: String) -> String {
        """
        {
            "id": "\(id)",
            "name": "World IBJJF Jiu-Jitsu Championship",
            "startDate": "2024-05-30",
            "endDate": "2024-06-02",
            "venue": "Walter Pyramid",
            "city": "Long Beach",
            "state": "CA",
            "country": "USA",
            "type": "gi",
            "status": "upcoming",
            "registrationStatus": "open",
            "eventLink": "https://ibjjf.com/events/world-championship",
            "categories": ["adult", "master"],
            "rankingPoints": 1000
        }
        """
    }
}
