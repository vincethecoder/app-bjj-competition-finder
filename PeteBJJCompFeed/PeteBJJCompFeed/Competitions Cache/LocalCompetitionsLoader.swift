//
//  LocalListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public final class LocalCompetitionsLoader {
    private let store: CompetitionsStore
    private let currentDate: () -> Date
    private let calender = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadCompetitionsResult?
    
    public init(store: CompetitionsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ competitions: [Competition], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCompetitions { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(competitions, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(competitions, timestamp) where self.isValid(timestamp):
                completion(.success(competitions.mapped))
                
            case .found, .empty:
                completion(.success([]))
                
            }
        }
    }
    
    private var maxCacheAgeInDays: Int { 7 }
    
    private func isValid(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
    
    private func cache(_ competitions: [Competition], with completion: @escaping (SaveResult) -> Void) {
        store.insert(competitions.localCompetitions, timestamp: self.currentDate()){ [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == Competition {
    var localCompetitions: [LocalCompetition] {
        return map {
            LocalCompetition(
                id: $0.id,
                name: $0.name,
                startDate: $0.startDate,
                endDate: $0.endDate,
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

private extension Array where Element == LocalCompetition {
    var mapped: [Competition] {
        return map {
            Competition(
                id: $0.id,
                name: $0.name,
                startDate: $0.startDate,
                endDate: $0.endDate,
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
