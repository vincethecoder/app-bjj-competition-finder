//
//  PosterScreenFilteringTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
@testable import PeteBJJCompFeedSwiftUI

struct PosterScreenFilteringTests {

    @Test func sectionsFilteredBy_keepsOnlyMatchingCardsAndDropsEmptySections() {
        let screen = PosterScreenMapper.map(makeFeed(screen: makeScreen()), locale: testLocale, calendar: testCalendar)

        let sections = screen.sections(filteredBy: "nogi")

        #expect(sections.map(\.id) == ["2026-05"])
        #expect(sections.map { $0.cards.map(\.id) } == [["nogi-worlds"]])
    }

    @Test(arguments: [nil, "all", "unknown"])
    func sectionsFilteredBy_showsEverythingForAllOrUnknownFilter(filterID: String?) {
        let screen = PosterScreenMapper.map(makeFeed(screen: makeScreen()), locale: testLocale, calendar: testCalendar)

        #expect(screen.sections(filteredBy: filterID) == screen.sections)
    }

    @Test func sectionsFilteredBy_keepsOnlyCardsThePredicateAcceptsToo() {
        let screen = PosterScreenMapper.map(makeFeed(screen: makeScreen()), locale: testLocale, calendar: testCalendar)

        let sections = screen.sections(filteredBy: "gi") { $0.id == "brasileiro" }

        #expect(sections.map { $0.cards.map(\.id) } == [["brasileiro"]])
    }

    @Test func countries_listsEachCountryOnceInAlphabeticalOrder() {
        let competitions = [
            uniqueCompetition(id: "worlds", country: "USA"),
            uniqueCompetition(id: "brasileiro", country: "Brazil"),
            uniqueCompetition(id: "pans", country: "USA"),
            uniqueCompetition(id: "euro", country: "Österreich"),
            uniqueCompetition(id: "missing", country: ""),
        ]

        let screen = PosterScreenMapper.map(makeFeed(competitions: competitions, screen: nil), locale: testLocale, calendar: testCalendar)

        #expect(screen.countries(locale: testLocale) == ["Brazil", "Österreich", "USA"])
    }

    @Test func countries_listsTranslatedNamesInTheReadersAlphabeticalOrder() {
        let competitions = [
            uniqueCompetition(id: "worlds", country: "USA"),
            uniqueCompetition(id: "brasileiro", country: "Brazil"),
            uniqueCompetition(id: "asian", country: "Japan"),
        ]
        let portuguese = Locale(identifier: "pt_BR")

        let screen = PosterScreenMapper.map(makeFeed(competitions: competitions, screen: nil), locale: portuguese, calendar: testCalendar)

        #expect(screen.countries(locale: portuguese) == ["Brasil", "Estados Unidos", "Japão"])
    }
}
