//
//  SharedTestHelpers.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyURL: URL {
    URL(string: "http://any-url.com")!
}

/// A fixed calendar and locale, so formatted dates don't depend on the machine running the tests.
let testCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
}()

let testLocale = Locale(identifier: "en_US")

func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    testCalendar.date(from: DateComponents(year: year, month: month, day: day))!
}

func uniqueCompetition(
    id: String = UUID().uuidString,
    name: String = "World IBJJF Jiu-Jitsu Championship",
    startDate: Date = date(2026, 5, 30),
    endDate: Date = date(2026, 6, 2),
    city: String = "Long Beach",
    state: String? = "CA",
    country: String = "USA",
    type: CompetitionType = .gi,
    registrationStatus: RegistrationStatus = .open,
    venue: String = "Walter Pyramid",
    registrationLink: URL? = nil,
    categories: [CompetitionCategory] = [.adult],
    rankingPoints: Int = 1000,
    notes: String? = nil
) -> Competition {
    Competition(
        id: id,
        name: name,
        startDate: startDate,
        endDate: endDate,
        venue: venue,
        city: city,
        state: state,
        country: country,
        type: type,
        status: .upcoming,
        registrationStatus: registrationStatus,
        registrationLink: registrationLink,
        eventLink: anyURL,
        categories: categories,
        rankingPoints: rankingPoints,
        notes: notes)
}

func makeFeed(competitions: [Competition] = [], screen: CompetitionsScreen?, cachedAt: Date? = nil) -> CompetitionsFeed {
    CompetitionsFeed(competitions: competitions, screen: screen, cachedAt: cachedAt)
}

let allFilter = CompetitionsScreen.Filter(id: "all", title: "All", criterion: .all)
let giFilter = CompetitionsScreen.Filter(id: "gi", title: "Gi", criterion: .type("gi"))
let noGiFilter = CompetitionsScreen.Filter(id: "nogi", title: "No-Gi", criterion: .type("nogi"))
let openFilter = CompetitionsScreen.Filter(id: "open", title: "Registration open", criterion: .registrationStatus("open"))

func makeScreen(
    title: String? = "Championships",
    filters: [CompetitionsScreen.Filter] = [allFilter, giFilter, noGiFilter, openFilter],
    sections: [CompetitionsScreen.Section] = [
        CompetitionsScreen.Section(id: "2026-05", title: "May 2026", cards: [makeCard(id: "worlds"), makeCard(id: "nogi-worlds", type: "nogi", registrationOpen: false)]),
        CompetitionsScreen.Section(id: "2026-06", title: "June 2026", cards: [makeCard(id: "brasileiro")]),
    ]
) -> CompetitionsScreen {
    CompetitionsScreen(
        title: title,
        empty: CompetitionsScreen.EmptyState(title: "No competitions", message: "Pull down to refresh."),
        filters: filters,
        sections: sections)
}

func makeCard(
    id: String,
    name: String = "World IBJJF Jiu-Jitsu Championship",
    dateLabel: String? = "May 30 – Jun 2",
    startDate: Date? = nil,
    endDate: Date? = nil,
    locationLabel: String? = "Long Beach, USA",
    imageURL: URL? = URL(string: "https://example.com/poster.jpg"),
    type: String = "gi",
    registrationOpen: Bool = true
) -> CompetitionsScreen.Card {
    CompetitionsScreen.Card(
        id: id,
        name: name,
        dateLabel: dateLabel,
        startDate: startDate,
        endDate: endDate,
        locationLabel: locationLabel,
        imageURL: imageURL,
        eventLink: anyURL,
        badges: [
            CompetitionsScreen.Badge(id: type, title: type, token: .type),
            registrationOpen
                ? CompetitionsScreen.Badge(id: "open", title: "Register", token: .registrationOpen)
                : CompetitionsScreen.Badge(id: "closed", title: "Ended", token: .registrationClosed),
        ])
}
