//
//  CompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public protocol CompetitionsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedCompetitions(compeletion: @escaping DeletionCompletion)
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve()
}
