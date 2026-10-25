//
//  PreviewCompetitionsFeedLoader.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

#if DEBUG
import Foundation
import PeteBJJCompFeed

/// Feeds SwiftUI previews with fixed results, without networking or Core Data.
final class PreviewCompetitionsFeedLoader: CompetitionsFeedLoader {
    enum Fixture {
        /// A server-driven screen with two sections.
        case loaded
        /// The first filter matches none of the cards.
        case filteredEmpty
        /// The server can't be reached and nothing is cached.
        case offline
        /// Every card's artwork fails to load.
        case imageFailed
    }

    private struct OfflineError: Error {}

    private let result: CompetitionsFeedLoader.Result

    init(_ fixture: Fixture) {
        result = switch fixture {
        case .loaded:
            .success(CompetitionsFeed(competitions: [], screen: Self.screen(filters: Self.filters, imageURL: nil)))
        case .filteredEmpty:
            .success(CompetitionsFeed(competitions: [], screen: Self.screen(filters: Self.filters.reversed(), imageURL: nil)))
        case .offline:
            .failure(OfflineError())
        case .imageFailed:
            .success(CompetitionsFeed(competitions: [], screen: Self.screen(filters: Self.filters, imageURL: URL(string: "https://artwork.invalid/poster.jpg"))))
        }
    }

    func loadFeed(completion: @escaping (CompetitionsFeedLoader.Result) -> Void) {
        completion(result)
    }

    private static let filters = [
        CompetitionsScreen.Filter(id: "all", title: "All", criterion: .all),
        CompetitionsScreen.Filter(id: "gi", title: "Gi", criterion: .type("gi")),
        CompetitionsScreen.Filter(id: "nogi", title: "No-Gi", criterion: .type("nogi")),
    ]

    private static func screen(filters: [CompetitionsScreen.Filter], imageURL: URL?) -> CompetitionsScreen {
        CompetitionsScreen(
            title: "Championships",
            empty: CompetitionsScreen.EmptyState(title: "No competitions", message: "Pull down to refresh."),
            filters: filters,
            sections: [
                CompetitionsScreen.Section(id: "2026-05", title: "May 2026", cards: [
                    card(id: "worlds", name: "World Jiu-Jitsu Championship", dates: "May 30 – Jun 2", location: "Long Beach, USA", imageURL: imageURL, registrationOpen: true),
                    card(id: "pans", name: "Pan American Championship", dates: "May 6 – 10", location: "Kissimmee, USA", imageURL: imageURL, registrationOpen: false),
                ]),
                CompetitionsScreen.Section(id: "2026-06", title: "June 2026", cards: [
                    card(id: "brasileiro", name: "Campeonato Brasileiro de Jiu-Jitsu", dates: "Jun 12 – 15", location: "São Paulo, Brazil", imageURL: imageURL, registrationOpen: true),
                ]),
            ])
    }

    private static func card(id: String, name: String, dates: String, location: String, imageURL: URL?, registrationOpen: Bool) -> CompetitionsScreen.Card {
        CompetitionsScreen.Card(
            id: id,
            name: name,
            dateLabel: dates,
            startDate: nil,
            endDate: nil,
            locationLabel: location,
            imageURL: imageURL,
            eventLink: URL(string: "https://example.com/events/\(id)")!,
            badges: [
                CompetitionsScreen.Badge(id: "gi", title: "Gi", token: .type),
                registrationOpen
                    ? CompetitionsScreen.Badge(id: "open", title: "Register", token: .registrationOpen)
                    : CompetitionsScreen.Badge(id: "closed", title: "Ended", token: .registrationClosed),
            ])
    }
}
#endif
