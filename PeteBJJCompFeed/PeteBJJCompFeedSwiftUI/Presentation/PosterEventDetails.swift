//
//  PosterEventDetails.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation

/// What the detail screen adds to a card, taken from the card's competition.
/// Display strings are already localized in the feed's locale.
public struct PosterEventDetails: Hashable, Sendable {
    public let venue: String?
    /// The divisions as one list, e.g. "Juvenile, Adult and Master".
    public let divisionsText: String?
    public let rankingPoints: Int?
    public let notes: String?
    /// Set only while registration is open, so the screen offers to register
    /// only when the link can still be used.
    public let registrationLink: URL?

    init(venue: String?, divisionsText: String?, rankingPoints: Int?, notes: String?, registrationLink: URL?) {
        self.venue = venue
        self.divisionsText = divisionsText
        self.rankingPoints = rankingPoints
        self.notes = notes
        self.registrationLink = registrationLink
    }
}
