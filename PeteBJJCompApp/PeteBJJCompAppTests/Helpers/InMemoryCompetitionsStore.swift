//
//  InMemoryCompetitionsStore.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

final class InMemoryCompetitionsStore: CompetitionsStore {
    private(set) var cache: CachedCompetitions?

    private init(cache: CachedCompetitions? = nil) {
        self.cache = cache
    }

    func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {
        cache = nil
        completion(.success(()))
    }

    func insert(_ competitions: [LocalCompetition], screen: Data?, timestamp: Date, completion: @escaping InsertionCompletion) {
        cache = CachedCompetitions(competitions: competitions, screen: screen, timestamp: timestamp)
        completion(.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(cache))
    }

    static var empty: InMemoryCompetitionsStore {
        InMemoryCompetitionsStore()
    }

    static var withExpiredCache: InMemoryCompetitionsStore {
        InMemoryCompetitionsStore(cache: CachedCompetitions(competitions: [], timestamp: .distantPast))
    }

    static var withNonExpiredCache: InMemoryCompetitionsStore {
        InMemoryCompetitionsStore(cache: CachedCompetitions(competitions: [], timestamp: .now))
    }
}
