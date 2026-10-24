//
//  CompetitionsAcceptanceTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Testing
import UIKit
import PeteBJJCompFeed
import PeteBJJCompFeediOS
@testable import PeteBJJCompApp

@MainActor
struct CompetitionsAcceptanceTests {

    @Test func onLaunch_displaysRemoteCompetitionsWhenCustomerHasConnectivity() throws {
        let competitions = try launch(httpClient: .online(response), store: .empty)

        #expect(competitions.numberOfRenderedCompetitionViews() == 2)
    }

    @Test func onLaunch_displaysCachedRemoteCompetitionsWhenCustomerHasNoConnectivity() throws {
        let sharedStore = InMemoryCompetitionsStore.empty
        _ = try launch(httpClient: .online(response), store: sharedStore)

        let offlineCompetitions = try launch(httpClient: .offline, store: sharedStore)

        #expect(offlineCompetitions.numberOfRenderedCompetitionViews() == 2)
    }

    @Test func onLaunch_displaysEmptyCompetitionsWhenCustomerHasNoConnectivityAndEmptyCache() throws {
        let competitions = try launch(httpClient: .offline, store: .empty)

        #expect(competitions.numberOfRenderedCompetitionViews() == 0)
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

    private func launch(httpClient: HTTPClientStub, store: InMemoryCompetitionsStore) throws -> CompetitionsViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        // Laying out the window runs the real appearance cycle, which loads
        // the feed. It only appears if configureWindow made the window visible.
        sut.window?.layoutIfNeeded()

        return try #require(sut.window?.rootViewController as? CompetitionsViewController)
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

    private func makeCompetitionsData() -> Data {
        Data("""
        {
            "competitions": [
                \(makeCompetitionJSON(id: "competition-1")),
                \(makeCompetitionJSON(id: "competition-2"))
            ]
        }
        """.utf8)
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

private extension CompetitionsViewController {
    func numberOfRenderedCompetitionViews() -> Int {
        tableView.numberOfRows(inSection: 0)
    }
}
