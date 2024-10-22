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
    private var retrievalCompeletions = [RetrievalCompletion]()
    
    func deleteCachedCompetitions(compeletion: @escaping DeletionCompletion) {
        deletionCompletions.append(compeletion)
        receivedMessages.append(.deleteCachedCompetitions)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(competitions, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
        retrievalCompeletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompeletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompeletions[index](.empty)
    }
    
    func completeRetrieval(with competitions: [LocalCompetition], timestamp: Date, at index: Int = 0) {
        retrievalCompeletions[index](.found(competitions: competitions, timestamp: timestamp))
    }
}
