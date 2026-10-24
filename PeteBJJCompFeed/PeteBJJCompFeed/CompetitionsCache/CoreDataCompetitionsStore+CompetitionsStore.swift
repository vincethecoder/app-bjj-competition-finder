//
//  CoreDataCompetitionsStore+CompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/29/24.
//

import CoreData

extension ManagedCache {
    var localCompetitions: [LocalCompetition] {
        return competitions?.compactMap { ($0 as? ManagedCompetition)?.toModel() } ?? []
    }
}

extension CoreDataCompetitionsStore: CompetitionsStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedCompetitions(competitions: $0.localCompetitions, screen: $0.screen, timestamp: $0.timestamp!)
                }
            })
        }
    }
    
    public func insert(_ competitions: [LocalCompetition], screen: Data?, timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.competitions = ManagedCache.mapped(competitions, in: context)
                managedCache.screen = screen
                try context.save()
            })
        }
    }
    
    public func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}
