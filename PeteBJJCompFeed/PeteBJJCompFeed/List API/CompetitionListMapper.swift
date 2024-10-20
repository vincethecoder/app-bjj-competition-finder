//
//  CompetitionListMapper.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/18/24.
//

import Foundation

enum CompetitionListMapper {
    private struct Root: Decodable {
        private let competitions: [RemoteCompetitionItem]
        
        private struct RemoteCompetitionItem: Decodable {
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
        
        var items: [Competition] {
            competitions.map {
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
                    notes: $0.notes)
            }
        }
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteCompetitionListLoader.Result {
        
        do {
            let _ = try JSONDecoder().decode(Root.self, from: data)
        } catch {
            print(error)
        }
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteCompetitionListLoader.Error.invalidData)
        }
        
        return .success(root.items)
    }
}

// MARK: Helpers

public extension Date {
    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("invalid date from dateString: \(dateString)")
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let _year = components.year,
              let _month = components.month,
              let _day = components.day else {
            fatalError("invalid components dateString: \(dateString)")
        }
        
        return Calendar.current.date(from: DateComponents(year: _year, month: _month, day: _day))!
    }
}
