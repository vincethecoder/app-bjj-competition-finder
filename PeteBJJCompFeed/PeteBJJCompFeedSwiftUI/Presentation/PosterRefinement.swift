//
//  PosterRefinement.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation

/// The date and location the user narrowed the feed to, on top of the
/// server's filter chips.
public struct PosterRefinement: Equatable, Sendable {
    public var dateRange: PosterDateRange
    /// `nil` shows events in every country.
    public var country: String?

    public init(dateRange: PosterDateRange = .anyDate, country: String? = nil) {
        self.dateRange = dateRange
        self.country = country
    }

    public var isActive: Bool {
        self != PosterRefinement()
    }

    func matches(_ card: PosterCard, now: Date, calendar: Calendar) -> Bool {
        dateRange.contains(start: card.startDate, end: card.endDate, now: now, calendar: calendar)
            && (country == nil || card.country == country)
    }
}
