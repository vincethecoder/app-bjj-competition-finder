//
//  XCTestCase+CompetitionsStoreSpecs.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/26/24.
//

import XCTest
import PeteBJJCompFeed

extension CompetitionsStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache: (competition: [LocalCompetition], timestamp: Date), to sut: CompetitionsStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.competition, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: CompetitionsStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedCompetitions { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: CompetitionsStore, toRetrieveTwice expectedResult: RetrieveCachedCompetitionResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: CompetitionsStore, toRetrieve expectedResult: RetrieveCachedCompetitionResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(competitions: expectedCompetitions, timestamp: expectedTimestamp),
                      .found(competitions: retrievedCompetitions, timestamp: retrievedTimestamp)):
                XCTAssertEqual(retrievedCompetitions, expectedCompetitions, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expectetd to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

