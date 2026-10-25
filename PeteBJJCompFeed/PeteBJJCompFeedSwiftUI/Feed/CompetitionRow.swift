//
//  CompetitionRow.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

/// The display data for one competition in the feed.
public struct CompetitionRow: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    /// Closed, so a one-day event (start equal to end) is a single date
    /// rather than an empty range.
    public let dates: ClosedRange<Date>
    public let location: String

    public init(_ competition: Competition) {
        id = competition.id
        name = competition.name

        // Bad data shouldn't crash the feed: a range requires lower <= upper.
        let start = min(competition.startDate, competition.endDate)
        let end = max(competition.startDate, competition.endDate)
        dates = start...end

        location = [competition.venue, competition.city, competition.state]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
