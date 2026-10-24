//
//  CompetitionsFeedTestHelpers.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

/// Midnight on the given day in the current time zone, which is how
/// `yyyy-MM-dd` strings in the payload are parsed.
func localDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}

func makeFeedCompetition(id: String = UUID().uuidString) -> Competition {
    Competition(
        id: id,
        name: "World IBJJF Jiu-Jitsu Championship",
        startDate: localDate(2026, 5, 30),
        endDate: localDate(2026, 6, 2),
        venue: "Walter Pyramid",
        city: "Long Beach",
        state: "CA",
        country: "USA",
        type: .gi,
        status: .upcoming,
        registrationStatus: .open,
        registrationLink: nil,
        eventLink: URL(string: "https://ibjjf.com/events/world-championship")!,
        categories: [.adult],
        rankingPoints: 1000,
        notes: nil)
}

func makeScreen(cardID: String = "worlds-2026") -> CompetitionsScreen {
    CompetitionsScreen(
        title: "Championships",
        empty: CompetitionsScreen.EmptyState(title: "No competitions", message: "Pull down to refresh."),
        filters: [
            CompetitionsScreen.Filter(id: "all", title: "All", criterion: .all),
            CompetitionsScreen.Filter(id: "gi", title: "Gi", criterion: .type("gi")),
            CompetitionsScreen.Filter(id: "nogi", title: "No-Gi", criterion: .type("nogi")),
            CompetitionsScreen.Filter(id: "open", title: "Registration open", criterion: .registrationStatus("open")),
        ],
        sections: [
            CompetitionsScreen.Section(id: "2026-05", title: "May 2026", cards: [
                CompetitionsScreen.Card(
                    id: cardID,
                    name: "World IBJJF Jiu-Jitsu Championship",
                    dateLabel: "May 30 – Jun 2",
                    startDate: localDate(2026, 5, 30),
                    endDate: localDate(2026, 6, 2),
                    locationLabel: "Long Beach, USA",
                    imageURL: URL(string: "https://example.com/worlds.jpg"),
                    eventLink: URL(string: "https://ibjjf.com/events/world-championship")!,
                    badges: [
                        CompetitionsScreen.Badge(id: "gi", title: "Gi", token: .type),
                        CompetitionsScreen.Badge(id: "open", title: "Registration open", token: .registrationOpen),
                    ]),
            ]),
        ])
}

extension Competition {
    var local: LocalCompetition {
        LocalCompetition(id: id, name: name, startDate: startDate, endDate: endDate, venue: venue, city: city, state: state, country: country, type: type, status: status, registrationStatus: registrationStatus, registrationLink: registrationLink, eventLink: eventLink, categories: categories, rankingPoints: rankingPoints, notes: notes)
    }
}
