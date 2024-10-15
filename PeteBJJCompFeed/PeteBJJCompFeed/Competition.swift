//
//  Competition.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

// MARK: - Competition

struct Competition {
    let id: UUID
    let name: String
    let startDate: Date
    let endDate: Date
    let venue: String
    let city: String
    let state: String?
    let country: String
    let type: CompetitionType
    let status: CompetitionStatus
    let registrationStatus: RegistrationStatus
    let registrationLink: URL?
    let eventLink: URL
    let categories: [Category]
    let rankingPoints: Int
    let notes: String?
}

// MARK: - CompetitionType

enum CompetitionType: String, Codable {
    case gi
    case nogi
}

// MARK: - CompetitionStatus

enum CompetitionStatus: String, Codable {
    case upcoming
    case ongoing
    case finished
    case cancelled
}

// MARK: - RegistrationStatus

enum RegistrationStatus: String, Codable {
    case open
    case closed
    case notOpen = "not_open"
    case invitationOnly = "invitation_only"
}

// MARK: - Category

enum Category: String, Codable {
    case kids
    case juvenile
    case adult
    case master
}
