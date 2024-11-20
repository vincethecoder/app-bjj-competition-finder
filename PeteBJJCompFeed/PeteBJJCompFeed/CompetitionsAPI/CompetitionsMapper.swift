//
//  CompetitiosMapper.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/18/24.
//

import Foundation

enum CompetitionsMapper {
    private struct Root: Decodable {
        let competitions: [RemoteCompetition]
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCompetition] {
        
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCompetitionsLoader.Error.invalidData
        }
        
        return root.competitions
    }
}

// MARK: Helpers

extension Array where Element == RemoteCompetition {
    var mapped: [Competition] {
        return map {
            Competition(
                id: $0.id,
                name: $0.name,
                startDate: Date.dateFromString($0.startDate),
                endDate: Date.dateFromString($0.endDate),
                venue: $0.venue,
                city: $0.city,
                state: $0.state,
                country: $0.country,
                type: $0.type,
                status: $0.status,
                registrationStatus: $0.registrationStatus,
                registrationLink: $0.registrationLink,
                eventLink: $0.eventLink,
                categories: $0.categories,
                rankingPoints: $0.rankingPoints,
                notes: $0.notes
            )
        }
    }
}
