//
//  RemoteCompetition.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/20/24.
//

import Foundation

struct RemoteCompetition: Decodable {
    let id: String
    let name: String
    let startDate: String
    let endDate: String
    let venue: String
    let city: String
    let state: String?
    let country: String
    let type: CompetitionType
    let status: CompetitionStatus
    let registrationStatus: RegistrationStatus
    let registrationLink: URL?
    let eventLink: URL
    let categories: [CompetitionCategory]
    let rankingPoints: Int
    let notes: String?
}
