//
//  PosterDateRange.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation

/// When an event has to take place to stay in the feed, counted from today.
public enum PosterDateRange: String, CaseIterable, Identifiable, Sendable {
    case anyDate
    case thisMonth
    case nextThreeMonths

    public var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .anyDate: .feedRefineAnyDate
        case .thisMonth: .feedRefineThisMonth
        case .nextThreeMonths: .feedRefineNextThreeMonths
        }
    }

    /// Whether an event running from `start` to `end` has at least one day in
    /// the range. An event without dates is only in `anyDate`.
    func contains(start: Date?, end: Date?, now: Date, calendar: Calendar) -> Bool {
        guard let window = window(now: now, calendar: calendar) else { return true }
        guard let start, let end else { return false }

        let firstDay = calendar.startOfDay(for: min(start, end))
        let lastDay = calendar.startOfDay(for: max(start, end))
        return firstDay < window.end && lastDay >= window.start
    }

    private func window(now: Date, calendar: Calendar) -> DateInterval? {
        switch self {
        case .anyDate:
            return nil
        case .thisMonth:
            return calendar.dateInterval(of: .month, for: now)
        case .nextThreeMonths:
            let today = calendar.startOfDay(for: now)
            return calendar.date(byAdding: .month, value: 3, to: today).map { DateInterval(start: today, end: $0) }
        }
    }
}
