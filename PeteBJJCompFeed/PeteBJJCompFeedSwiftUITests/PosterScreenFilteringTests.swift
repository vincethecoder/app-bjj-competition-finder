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
}
