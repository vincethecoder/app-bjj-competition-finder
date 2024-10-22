//
//  LocalCompetition.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/22/24.
//

import Foundation

public struct LocalCompetition: Equatable {
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
