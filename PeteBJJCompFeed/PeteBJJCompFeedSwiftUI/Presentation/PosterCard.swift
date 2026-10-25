//
//  PosterCard.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// One event card, ready to draw.
public struct PosterCard: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let dateText: String?
    public let locationText: String?
    public let imageURL: URL?
    public let eventLink: URL
    public let badges: [PosterBadge]

    /// The values filters match on, e.g. `"gi"` and `"open"`.
    let type: String?
    let registrationStatus: String?

    init(
        id: String,
        name: String,
        dateText: String?,
        locationText: String?,
        imageURL: URL?,
        eventLink: URL,
        badges: [PosterBadge],
        type: String?,
        registrationStatus: String?
    ) {
        self.id = id
        self.name = name
        self.dateText = dateText
        self.locationText = locationText
        self.imageURL = imageURL
        self.eventLink = eventLink
        self.badges = badges
        self.type = type
        self.registrationStatus = registrationStatus
    }

    /// The first letter of the name, shown on the poster when there's no artwork.
    public var initial: String {
        name.first.map { String($0).localizedUppercase } ?? ""
    }

    func matches(_ criterion: PosterFilter.Criterion) -> Bool {
        switch criterion {
        case .all:
            true
        case let .type(value):
            type == value
        case let .registrationStatus(value):
            registrationStatus == value
        @unknown default:
            false
        }
    }
}
