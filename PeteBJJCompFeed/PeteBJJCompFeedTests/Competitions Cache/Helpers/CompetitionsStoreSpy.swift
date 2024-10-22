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
        case deleteCachedList
        case insert([LocalCompetition], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedList(compeletion: @escaping DeletionCompletion) {
        deletionCompletions.append(compeletion)
        receivedMessages.append(.deleteCachedList)
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
}
