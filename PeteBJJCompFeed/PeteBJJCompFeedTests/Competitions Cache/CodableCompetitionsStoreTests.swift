//
//  CodableCompetitionsStoreTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/23/24.
//

import XCTest
import PeteBJJCompFeed

final class CodableCompetitionStore {
    
    func retrieve(completion: @escaping CompetitionsStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableCompetitionsStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableCompetitionStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
