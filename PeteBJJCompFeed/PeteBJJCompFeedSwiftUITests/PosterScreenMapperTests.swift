//
//  PosterScreenMapperTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

struct PosterScreenMapperTests {

    // MARK: - Server-driven screen

    @Test func map_usesServerCopyAndOrder() throws {
        let screen = map(makeFeed(screen: makeScreen()))

        #expect(screen.title == "Championships")
        #expect(screen.emptyTitle == "No competitions")
        #expect(screen.emptyMessage == "Pull down to refresh.")
        #expect(screen.filters.map(\.id) == ["all", "gi", "nogi", "open"])
        #expect(screen.sections.map(\.title) == ["May 2026", "June 2026"])

        let card = try #require(screen.sections.first?.cards.first)
        #expect(card.dateText == "May 30 – Jun 2")
        #expect(card.locationText == "Long Beach, USA")
        #expect(card.badges.map(\.token) == [.type, .registrationOpen])
    }

    @Test func map_fallsBackToLocalizedCopyWhenServerOmitsIt() {
        let screen = map(makeFeed(screen: CompetitionsScreen(title: nil, empty: nil, filters: [], sections: [])))

        #expect(screen.title == localized(.feedViewTitle))
        #expect(screen.emptyTitle == localized(.feedViewEmptyTitle))
        #expect(screen.emptyMessage == localized(.feedViewEmptyDescription))
    }

    @Test func map_formatsCardDatesOnDeviceWhenServerSendsNoLabel() throws {
        let card = makeCard(id: "worlds", dateLabel: nil, startDate: date(2026, 5, 30), endDate: date(2026, 6, 2))

        let mapped = try #require(mapCard(card))

        #expect(mapped.dateText == dates.eventDates(from: date(2026, 5, 30), to: date(2026, 6, 2)))
        #expect(mapped.dateText?.contains("May 30") == true)
        #expect(mapped.dateText?.contains("Jun 2") == true)
    }

    @Test func map_completesCardFromItsCompetitionWhenServerOmitsDatesAndLocation() throws {
        let competition = uniqueCompetition(id: "worlds", city: "Long Beach", state: "CA", country: "USA", type: .nogi, registrationStatus: .closed)
        let card = makeCard(id: "worlds", dateLabel: nil, locationLabel: nil)

        let mapped = try #require(mapCard(card, competitions: [competition]))

        #expect(mapped.dateText == dates.eventDates(from: competition.startDate, to: competition.endDate))
        #expect(mapped.locationText == "Long Beach, CA, USA")
        #expect(mapped.matches(.type("nogi")))
        #expect(mapped.matches(.registrationStatus("closed")))
    }

    @Test func map_keepsMissingImageAsNoArtwork() throws {
        let mapped = try #require(mapCard(makeCard(id: "worlds", imageURL: nil)))

        #expect(mapped.imageURL == nil)
        #expect(mapped.initial == "W")
    }

    @Test func map_dropsCardsWithoutAMatchingCompetitionWhenPayloadHasCompetitions() {
        let screen = map(makeFeed(competitions: [uniqueCompetition(id: "worlds")], screen: makeScreen()))

        #expect(screen.sections.map { $0.cards.map(\.id) } == [["worlds"]])
    }

    @Test func map_keepsFirstOfRepeatedCardsInASection() {
        let screen = makeScreen(sections: [
            CompetitionsScreen.Section(id: "section", title: "Section", cards: [
                makeCard(id: "worlds", name: "First"),
                makeCard(id: "worlds", name: "Repeat"),
            ]),
        ])

        let mapped = map(makeFeed(screen: screen))

        #expect(mapped.sections.first?.cards.map(\.name) == ["First"])
    }

    @Test func map_matchesFiltersOnBadgesWhenCardHasNoCompetition() throws {
        let mapped = try #require(mapCard(makeCard(id: "nogi-worlds", type: "nogi", registrationOpen: false)))

        #expect(mapped.matches(.type("nogi")))
        #expect(!mapped.matches(.type("gi")))
        #expect(mapped.matches(.registrationStatus("closed")))
        #expect(!mapped.matches(.registrationStatus("open")))
    }

    // MARK: - Screen built on the device

    @Test func map_groupsCompetitionsByMonthInDateOrderWhenScreenIsMissing() {
        let june = uniqueCompetition(id: "june", startDate: date(2026, 6, 12), endDate: date(2026, 6, 15))
        let lateMay = uniqueCompetition(id: "late-may", startDate: date(2026, 5, 30), endDate: date(2026, 6, 2))
        let earlyMay = uniqueCompetition(id: "early-may", startDate: date(2026, 5, 6), endDate: date(2026, 5, 10))

        let screen = map(makeFeed(competitions: [june, lateMay, earlyMay], screen: nil))

        #expect(screen.title == localized(.feedViewTitle))
        #expect(screen.sections.map(\.title) == ["May 2026", "June 2026"])
        #expect(screen.sections.map { $0.cards.map(\.id) } == [["early-may", "late-may"], ["june"]])
        #expect(screen.filters.map(\.title) == [localized(.feedFilterAll), localized(.feedBadgeGi), localized(.feedBadgeNogi), localized(.feedFilterRegistrationOpen)])
    }

    @Test func map_buildsCardWithoutArtworkAndWithBadgesFromCompetition() throws {
        let competition = uniqueCompetition(type: .gi, registrationStatus: .open)

        let card = try #require(map(makeFeed(competitions: [competition], screen: nil)).sections.first?.cards.first)

        #expect(card.id == competition.id)
        #expect(card.name == competition.name)
        #expect(card.imageURL == nil)
        #expect(card.eventLink == competition.eventLink)
        #expect(card.badges == [
            PosterBadge(id: "gi", title: localized(.feedBadgeGi), token: .type),
            PosterBadge(id: "open", title: localized(.feedBadgeRegistrationOpen), token: .registrationOpen),
        ])
    }

    @Test func map_joinsCityStateAndCountryIntoLocation() throws {
        let card = try #require(deviceCard(for: uniqueCompetition(city: "Long Beach", state: "CA", country: "USA")))

        #expect(card.locationText == "Long Beach, CA, USA")
    }

    @Test(arguments: [nil, ""])
    func map_omitsMissingStateFromLocation(state: String?) throws {
        let card = try #require(deviceCard(for: uniqueCompetition(city: "São Paulo", state: state, country: "Brazil")))

        #expect(card.locationText == "São Paulo, Brazil")
    }

    @Test func map_ordersDatesWhenEndDatePrecedesStartDate() throws {
        let reversed = try #require(deviceCard(for: uniqueCompetition(startDate: date(2026, 6, 2), endDate: date(2026, 5, 30))))
        let ordered = try #require(deviceCard(for: uniqueCompetition(startDate: date(2026, 5, 30), endDate: date(2026, 6, 2))))

        #expect(reversed.dateText == ordered.dateText)
    }

    @Test func map_showsOneDateForOneDayEvent() throws {
        let card = try #require(deviceCard(for: uniqueCompetition(startDate: date(2026, 5, 30), endDate: date(2026, 5, 30))))

        #expect(card.dateText == date(2026, 5, 30).formatted(Date.FormatStyle(locale: testLocale, calendar: testCalendar, timeZone: testCalendar.timeZone).month(.abbreviated).day()))
    }

    // MARK: - Details

    @Test func map_buildsDetailsFromCompetition() throws {
        let registrationLink = try #require(URL(string: "https://example.com/register"))
        let competition = uniqueCompetition(
            registrationStatus: .open,
            venue: "Walter Pyramid",
            registrationLink: registrationLink,
            categories: [.juvenile, .adult, .master],
            rankingPoints: 1000,
            notes: "  Weigh-in before the first match.\n")

        let details = try #require(deviceCard(for: competition)?.details)

        #expect(details.venue == "Walter Pyramid")
        #expect(details.divisionsText == [localized(.detailDivisionJuvenile), localized(.detailDivisionAdult), localized(.detailDivisionMaster)].formatted(.list(type: .and).locale(testLocale)))
        #expect(details.rankingPoints == 1000)
        #expect(details.notes == "Weigh-in before the first match.")
        #expect(details.registrationLink == registrationLink)
    }

    @Test(arguments: [RegistrationStatus.closed, .notOpen, .invitationOnly])
    func map_offersRegistrationLinkOnlyWhileRegistrationIsOpen(status: RegistrationStatus) throws {
        let competition = uniqueCompetition(registrationStatus: status, registrationLink: URL(string: "https://example.com/register"))

        let details = try #require(deviceCard(for: competition)?.details)

        #expect(details.registrationLink == nil)
    }

    @Test func map_leavesOutDetailsTheCompetitionHasNoValueFor() throws {
        let competition = uniqueCompetition(venue: "", categories: [], rankingPoints: 0, notes: " \n ")

        let details = try #require(deviceCard(for: competition)?.details)

        #expect(details.venue == nil)
        #expect(details.divisionsText == nil)
        #expect(details.rankingPoints == nil)
        #expect(details.notes == nil)
    }

    @Test func map_addsCompetitionDetailsToServerCard() throws {
        let card = try #require(mapCard(makeCard(id: "worlds"), competitions: [uniqueCompetition(id: "worlds", venue: "Walter Pyramid")]))

        #expect(card.details?.venue == "Walter Pyramid")
    }

    @Test func map_hasNoDetailsForServerCardWithoutCompetition() throws {
        let card = try #require(mapCard(makeCard(id: "worlds")))

        #expect(card.details == nil)
    }

    // MARK: - Refinement values

    @Test func map_takesRefinementValuesFromCompetition() throws {
        let competition = uniqueCompetition(startDate: date(2026, 5, 30), endDate: date(2026, 6, 2), country: "USA")

        let card = try #require(deviceCard(for: competition))

        #expect(card.startDate == date(2026, 5, 30))
        #expect(card.endDate == date(2026, 6, 2))
        #expect(card.country == "USA")
    }

    @Test func map_prefersServerCardDatesAndTakesCountryFromItsCompetition() throws {
        let card = makeCard(id: "worlds", startDate: date(2026, 5, 28), endDate: date(2026, 5, 31))
        let competition = uniqueCompetition(id: "worlds", startDate: date(2026, 5, 30), endDate: date(2026, 6, 2), country: "Brazil")

        let mapped = try #require(mapCard(card, competitions: [competition]))

        #expect(mapped.startDate == date(2026, 5, 28))
        #expect(mapped.endDate == date(2026, 5, 31))
        #expect(mapped.country == "Brazil")
    }

    @Test func map_hasNoCountryForServerCardWithoutCompetition() throws {
        let mapped = try #require(mapCard(makeCard(id: "worlds", startDate: date(2026, 5, 28), endDate: date(2026, 5, 31))))

        #expect(mapped.startDate == date(2026, 5, 28))
        #expect(mapped.country == nil)
    }

    // MARK: - Helpers

    /// Catalog copy in the locale the mapper is given.
    private func localized(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = testLocale
        return String(localized: resource)
    }

    private var dates: PosterDateFormatting {
        PosterDateFormatting(locale: testLocale, calendar: testCalendar)
    }

    private func map(_ feed: CompetitionsFeed) -> PosterScreen {
        PosterScreenMapper.map(feed, locale: testLocale, calendar: testCalendar)
    }

    private func mapCard(_ card: CompetitionsScreen.Card, competitions: [Competition] = []) -> PosterCard? {
        let screen = makeScreen(sections: [CompetitionsScreen.Section(id: "section", title: "Section", cards: [card])])
        return map(makeFeed(competitions: competitions, screen: screen)).sections.first?.cards.first
    }

    private func deviceCard(for competition: Competition) -> PosterCard? {
        map(makeFeed(competitions: [competition], screen: nil)).sections.first?.cards.first
    }
}
