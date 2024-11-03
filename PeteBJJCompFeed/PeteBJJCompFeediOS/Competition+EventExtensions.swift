//
//  Competition+EventExtensions.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/3/24.
//

import Foundation
import PeteBJJCompFeed

public extension Competition {
    func toCompetitiveEvent() -> CompetitiveEvent {
        return CompetitiveEvent(
            date: formattedDateRange,
            name: name,
            venue: formattedVenue
        )
    }
}

// MARK: - Date Formatters

extension Competition {
    private var formattedDateRange: String {
        formatDateRange(startDate: startDate, endDate: endDate)
    }

    private func formatDateRange(startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        guard startString != endString else {
            return startString
        }
        return "\(startString)-\(endString)"
    }
    
    private var formattedVenue: String {
        var components: [String] = []
        
        if !venue.isEmpty {
            components.append(venue)
        }
        
        if !city.isEmpty {
            if let state = state, !state.isEmpty {
                components.append("\(city), \(state)")
            } else {
                components.append(city)
            }
        }
        
        return components.joined(separator: ", ")
    }
}

extension Array where Element == Competition {
    public func toCompetitiveEvents() -> [CompetitiveEvent] {
        map { $0.toCompetitiveEvent() }
    }
}
