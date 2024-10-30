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
    
    public init(store: CompetitionsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

public protocol CompetitionsCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ competitions: [Competition], completion: @escaping (Result) -> Void)
}

extension LocalCompetitionsLoader {
    public typealias SaveResult = CompetitionsCache.Result
    public func save(_ competitions: [Competition], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCompetitions { [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(competitions, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ competitions: [Competition], with completion: @escaping (SaveResult) -> Void) {
        store.insert(competitions.local, timestamp: self.currentDate()){ [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        }
    }
}
extension LocalCompetitionsLoader {
    public typealias LoadResult = Swift.Result<[Competition], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                self.store.deleteCachedCompetitions { _ in }
                completion(.failure(error))
                
            case let .success(.some(cache)) where CompetitionsCachePolicy.isValid(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.competitions.mapped))
            
            case .success:
                completion(.success([]))
                
            }
        }
    }
}

extension LocalCompetitionsLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self.store.deleteCachedCompetitions(completion: completion)

            case let .success(.some(cache)) where !CompetitionsCachePolicy.isValid(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedCompetitions(completion: completion)

            case .success:
                completion(.success(()))
            }
        }
    }
}


private extension Array where Element == Competition {
    var local: [LocalCompetition] {
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
