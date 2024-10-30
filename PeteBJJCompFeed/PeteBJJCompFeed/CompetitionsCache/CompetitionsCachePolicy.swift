//
//  CompetitionsCachePolicy.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/23/24.
//

import Foundation

enum CompetitionsCachePolicy {

    private static let calender = Calendar(identifier: .gregorian)

    private static var maxCacheAgeInDays: Int { 7 }
    
    static func isValid(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
