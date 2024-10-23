//
//  Competition.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

// MARK: - Competition

public struct Competition: Decodable, Equatable {
    public let id: String
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let venue: String
    public let city: String
    public let state: String?
    public let country: String
    public let type: CompetitionType
    public let status: CompetitionStatus
    public let registrationStatus: RegistrationStatus
    public let registrationLink: URL?
    public let eventLink: URL
    public let categories: [CompetitionCategory]
    public let rankingPoints: Int
    public let notes: String?
    
    public init(
        id: String,
        name: String,
        startDate: Date,
        endDate: Date,
        venue: String,
        city: String,
        state: String?,
        country: String,
        type: CompetitionType,
        status: CompetitionStatus,
        registrationStatus: RegistrationStatus,
        registrationLink: URL?,
        eventLink: URL,
        categories: [CompetitionCategory],
        rankingPoints: Int,
        notes: String?
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.venue = venue
        self.city = city
        self.state = state
        self.country = country
        self.type = type
        self.status = status
        self.registrationStatus = registrationStatus
        self.registrationLink = registrationLink
        self.eventLink = eventLink
        self.categories = categories
        self.rankingPoints = rankingPoints
        self.notes = notes
    }
}

// MARK: - CompetitionType

public enum CompetitionType: String, Codable {
    case gi
    case nogi
}

// MARK: - CompetitionStatus

public enum CompetitionStatus: String, Codable {
    case upcoming
    case ongoing
    case finished
    case cancelled
}

// MARK: - RegistrationStatus

public enum RegistrationStatus: String, Codable {
    case open
    case closed
    case notOpen = "not_open"
    case invitationOnly = "invitation_only"
}

// MARK: - Category

public enum CompetitionCategory: String, Codable {
    case kids
    case juvenile
    case adult
    case master
}
