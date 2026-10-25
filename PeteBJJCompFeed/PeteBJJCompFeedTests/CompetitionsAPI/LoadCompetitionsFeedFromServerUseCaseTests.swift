//
//  LoadCompetitionsFeedFromServerUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed

final class LoadCompetitionsFeedFromServerUseCaseTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        #expect(client.requestedURLs.isEmpty)
    }

    @Test func loadFeed_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.loadFeed { _ in }

        #expect(client.requestedURLs == [url])
    }

    @Test func loadFeed_deliversConnectivityErrorOnClientError() throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(with: anyNSError) }

        #expect(throws: RemoteCompetitionsFeedLoader.Error.connectivity) { try result.get() }
    }

    @Test(arguments: [199, 201, 300, 400, 500])
    func loadFeed_deliversInvalidDataErrorOnNon200HTTPResponse(statusCode: Int) throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(withStatusCode: statusCode, data: payload(screen: fullScreenJSON)) }

        #expect(throws: RemoteCompetitionsFeedLoader.Error.invalidData) { try result.get() }
    }

    @Test func loadFeed_deliversInvalidDataErrorWhenCompetitionsAreMissing() throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: Data(#"{ "screen": \#(fullScreenJSON) }"#.utf8)) }

        #expect(throws: RemoteCompetitionsFeedLoader.Error.invalidData) { try result.get() }
    }

    @Test func loadFeed_deliversFullScreenWithCompetitions() throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: payload(screen: fullScreenJSON)) }

        let feed = try result.get()
        #expect(feed.competitions == [makeFeedCompetition(id: "worlds-2026")])
        #expect(feed.screen == makeScreen())
    }

    @Test func loadFeed_deliversNoScreenOnPayloadWithOnlyCompetitions() throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: payload(screen: nil)) }

        let feed = try result.get()
        #expect(feed.competitions == [makeFeedCompetition(id: "worlds-2026")])
        #expect(feed.screen == nil)
    }

    @Test func loadFeed_ignoresUnknownLayoutAndSkipsUnknownBadgesAndFilters() throws {
        let (sut, client) = makeSUT()
        let screen = """
        {
            "title": "Championships",
            "layout": { "style": "carousel" },
            "filters": [
                { "id": "all", "title": "All", "field": "none", "value": null },
                { "id": "belt", "title": "Black belt", "field": "belt", "value": "black" }
            ],
            "sections": [{
                "id": "2026-05",
                "title": "May 2026",
                "cards": [{
                    "id": "worlds-2026",
                    "name": "Worlds",
                    "eventLink": "https://ibjjf.com/events/world-championship",
                    "ticketPrice": 120,
                    "badges": [
                        { "id": "gi", "title": "Gi", "token": "type" },
                        { "id": "hot", "title": "Selling fast", "token": "promo", "color": "#FF0000" }
                    ]
                }]
            }]
        }
        """

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: payload(screen: screen)) }

        let decoded = try #require(try result.get().screen)
        #expect(decoded.filters == [CompetitionsScreen.Filter(id: "all", title: "All", criterion: .all)])
        #expect(decoded.sections.map(\.id) == ["2026-05"])
        #expect(decoded.sections.first?.cards.first?.badges == [CompetitionsScreen.Badge(id: "gi", title: "Gi", token: .type)])
    }

    @Test func loadFeed_skipsInvalidCardsAndToleratesInvalidOptionalFields() throws {
        let (sut, client) = makeSUT()
        let screen = """
        {
            "sections": [{
                "id": "2026-05",
                "title": "May 2026",
                "cards": [
                    { "id": "no-link", "name": "Missing event link" },
                    {
                        "id": "worlds-2026",
                        "name": "Worlds",
                        "startDate": "30/05/2026",
                        "endDate": 20260602,
                        "imageURL": "",
                        "eventLink": "https://ibjjf.com/events/world-championship"
                    }
                ]
            }]
        }
        """

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: payload(screen: screen)) }

        let card = try #require(try result.get().screen?.sections.first?.cards.first)
        #expect(try result.get().screen?.sections.first?.cards.count == 1)
        #expect(card.id == "worlds-2026")
        #expect(card.startDate == nil)
        #expect(card.endDate == nil)
        #expect(card.imageURL == nil)
        #expect(card.badges.isEmpty)
    }

    @Test(arguments: [#""not a screen""#, "[]", #"{ "sections": 42, "filters": "all" }"#])
    func loadFeed_deliversCompetitionsWhenScreenIsMalformed(screen: String) throws {
        let (sut, client) = makeSUT()

        let result = try loadResult(of: sut) { client.complete(withStatusCode: 200, data: payload(screen: screen)) }

        let feed = try result.get()
        #expect(feed.competitions == [makeFeedCompetition(id: "worlds-2026")])
        #expect(feed.screen?.sections.isEmpty ?? true)
    }

    @Test func loadFeed_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteCompetitionsFeedLoader? = RemoteCompetitionsFeedLoader(url: anyURL, client: client)

        var capturedResults = [RemoteCompetitionsFeedLoader.Result]()
        sut?.loadFeed { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: payload(screen: nil))

        #expect(capturedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = anyURL, sourceLocation: SourceLocation = #_sourceLocation) -> (sut: RemoteCompetitionsFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionsFeedLoader(url: url, client: client)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        leakTracker.track(client, sourceLocation: sourceLocation)
        return (sut, client)
    }

    private func loadResult(of sut: RemoteCompetitionsFeedLoader, when action: () -> Void, sourceLocation: SourceLocation = #_sourceLocation) throws -> RemoteCompetitionsFeedLoader.Result {
        var receivedResult: RemoteCompetitionsFeedLoader.Result?
        sut.loadFeed { receivedResult = $0 }

        action()

        return try #require(receivedResult, "Expected loadFeed to complete", sourceLocation: sourceLocation)
    }

    private func payload(screen: String?) -> Data {
        let screenEntry = screen.map { #", "screen": \#($0)"# } ?? ""
        return Data(#"{ "competitions": [\#(competitionJSON)]\#(screenEntry) }"#.utf8)
    }

    private let competitionJSON = """
    {
        "id": "worlds-2026",
        "name": "World IBJJF Jiu-Jitsu Championship",
        "startDate": "2026-05-30",
        "endDate": "2026-06-02",
        "venue": "Walter Pyramid",
        "city": "Long Beach",
        "state": "CA",
        "country": "USA",
        "type": "gi",
        "status": "upcoming",
        "registrationStatus": "open",
        "eventLink": "https://ibjjf.com/events/world-championship",
        "categories": ["adult"],
        "rankingPoints": 1000
    }
    """

    /// The `screen` from the server-driven contract, verbatim.
    private let fullScreenJSON = """
    {
        "title": "Championships",
        "empty": { "title": "No competitions", "message": "Pull down to refresh." },
        "filters": [
            { "id": "all", "title": "All", "field": "none", "value": null },
            { "id": "gi", "title": "Gi", "field": "type", "value": "gi" },
            { "id": "nogi", "title": "No-Gi", "field": "type", "value": "nogi" },
            { "id": "open", "title": "Registration open", "field": "registrationStatus", "value": "open" }
        ],
        "layout": { "style": "posterGrid" },
        "sections": [
            {
                "id": "2026-05",
                "title": "May 2026",
                "cards": [
                    {
                        "id": "worlds-2026",
                        "name": "World IBJJF Jiu-Jitsu Championship",
                        "dateLabel": "May 30 – Jun 2",
                        "startDate": "2026-05-30",
                        "endDate": "2026-06-02",
                        "locationLabel": "Long Beach, USA",
                        "imageURL": "https://example.com/worlds.jpg",
                        "eventLink": "https://ibjjf.com/events/world-championship",
                        "badges": [
                            { "id": "gi", "title": "Gi", "token": "type" },
                            { "id": "open", "title": "Registration open", "token": "registrationOpen" }
                        ]
                    }
                ]
            }
        ]
    }
    """
}
