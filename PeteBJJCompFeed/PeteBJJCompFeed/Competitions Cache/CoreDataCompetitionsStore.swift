//
//  CoreDataCompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/27/24.
//

import Foundation

public final class CoreDataCompetitionsStore: CompetitionsStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {

    }
}
