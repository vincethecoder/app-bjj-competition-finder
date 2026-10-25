//
//  PosterDateFormatting.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Formats event dates on the device, for cards the server didn't label.
struct PosterDateFormatting {
    let locale: Locale
    let calendar: Calendar

    /// "May 30 – Jun 2" for a range, "May 30" for a one-day event.
    /// Reversed dates are put in order rather than shown backwards.
    func eventDates(from start: Date?, to end: Date?) -> String? {
        switch (start, end) {
        case (nil, nil):
            nil
        case let (date?, nil), let (nil, date?):
            day(date)
        case let (start?, end?):
            if calendar.isDate(start, inSameDayAs: end) {
                day(start)
            } else {
                (min(start, end)..<max(start, end)).formatted(
                    Date.IntervalFormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
                        .month(.abbreviated)
                        .day())
            }
        }
    }

    /// "May 2026", used as a section title.
    func month(of date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone, capitalizationContext: .beginningOfSentence)
                .month(.wide)
                .year())
    }

    private func day(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone)
                .month(.abbreviated)
                .day())
    }
}
