//
//  CompetitionsStoreSpy.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/22/24.
//

import Foundation
import PeteBJJCompFeed

class CompetitionsStoreSpy: CompetitionsStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedCompetitions
        case insert([LocalCompetition], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalcompletions = [RetrievalCompletion]()
    
    func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedCompetitions)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(competitions, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalcompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalcompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalcompletions[index](.success(.none))
    }
    
    func completeRetrieval(with competitions: [LocalCompetition], timestamp: Date, at index: Int = 0) {
        retrievalcompletions[index](.success(CachedCompetitions(competitions: competitions, timestamp: timestamp)))
    }
}
