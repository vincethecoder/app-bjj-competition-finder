//
//  PosterDateRangeTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation
import Testing
@testable import PeteBJJCompFeedSwiftUI

struct PosterDateRangeTests {
    private let now = date(2026, 10, 25).addingTimeInterval(15 * 60 * 60)

    @Test func anyDate_containsEveryEventIncludingOnesWithoutDates() {
        #expect(contains(.anyDate, from: date(2020, 1, 1), to: date(2020, 1, 2)))
        #expect(contains(.anyDate, from: nil, to: nil))
    }

    @Test(arguments: [PosterDateRange.thisMonth, .nextThreeMonths])
    func range_leavesOutEventsWithoutDates(range: PosterDateRange) {
        #expect(!contains(range, from: nil, to: date(2026, 10, 26)))
        #expect(!contains(range, from: date(2026, 10, 26), to: nil))
    }

    @Test func thisMonth_containsEventsWithADayInTheCalendarMonth() {
        #expect(contains(.thisMonth, from: date(2026, 10, 1), to: date(2026, 10, 2)))
        #expect(contains(.thisMonth, from: date(2026, 10, 31), to: date(2026, 10, 31)))
        #expect(contains(.thisMonth, from: date(2026, 9, 29), to: date(2026, 10, 1)))
        #expect(contains(.thisMonth, from: date(2026, 10, 31), to: date(2026, 11, 2)))
    }

    @Test func thisMonth_leavesOutEventsInOtherMonths() {
        #expect(!contains(.thisMonth, from: date(2026, 9, 28), to: date(2026, 9, 30)))
        #expect(!contains(.thisMonth, from: date(2026, 11, 1), to: date(2026, 11, 3)))
    }

    @Test func nextThreeMonths_containsEventsFromTodayUntilThreeMonthsFromToday() {
        #expect(contains(.nextThreeMonths, from: date(2026, 10, 24), to: date(2026, 10, 25)))
        #expect(contains(.nextThreeMonths, from: date(2026, 12, 10), to: date(2026, 12, 13)))
        #expect(contains(.nextThreeMonths, from: date(2027, 1, 24), to: date(2027, 1, 26)))
    }

    @Test func nextThreeMonths_leavesOutPastEventsAndEventsAfterThreeMonths() {
        #expect(!contains(.nextThreeMonths, from: date(2026, 10, 20), to: date(2026, 10, 24)))
        #expect(!contains(.nextThreeMonths, from: date(2027, 1, 25), to: date(2027, 1, 26)))
    }

    @Test func range_readsReversedDatesInOrder() {
        #expect(contains(.thisMonth, from: date(2026, 10, 2), to: date(2026, 9, 30)))
        #expect(!contains(.nextThreeMonths, from: date(2026, 10, 24), to: date(2026, 10, 20)))
    }

    // MARK: - Helpers

    private func contains(_ range: PosterDateRange, from start: Date?, to end: Date?) -> Bool {
        range.contains(start: start, end: end, now: now, calendar: testCalendar)
    }
}
