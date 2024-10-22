//
//  LocalListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public final class LocalListLoader {
    private let store: ListStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public init(store: ListStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [Competition], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedList { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [Competition], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.localCompetitions, timestamp: self.currentDate()){ [weak self] error in
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
