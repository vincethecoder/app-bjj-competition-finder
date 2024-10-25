//
//  CompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public enum RetrieveCachedCompetitionResult {
    case empty
    case found(competitions: [LocalCompetition], timestamp: Date)
    case failure(Error)
}

public protocol CompetitionsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedCompetitionResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedCompetitions(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion)
   
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
