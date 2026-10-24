//
//  CompetitionsScreen+Card.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen {
    /// One event as the server presents it. Its `id` matches a `Competition`
    /// when the payload includes both. Display strings are already localized
    /// when present; the structured dates let clients format them otherwise.
    public struct Card: Codable, Equatable, Identifiable, Sendable {
        public let id: String
        public let name: String
        public let dateLabel: String?
        public let startDate: Date?
        public let endDate: Date?
        public let locationLabel: String?
        public let imageURL: URL?
        public let eventLink: URL
        public let badges: [Badge]

        public init(
            id: String,
            name: String,
            dateLabel: String?,
            startDate: Date?,
            endDate: Date?,
            locationLabel: String?,
            imageURL: URL?,
            eventLink: URL,
            badges: [Badge]
        ) {
            self.id = id
            self.name = name
            self.dateLabel = dateLabel
            self.startDate = startDate
            self.endDate = endDate
            self.locationLabel = locationLabel
            self.imageURL = imageURL
            self.eventLink = eventLink
            self.badges = badges
        }
    }
}
