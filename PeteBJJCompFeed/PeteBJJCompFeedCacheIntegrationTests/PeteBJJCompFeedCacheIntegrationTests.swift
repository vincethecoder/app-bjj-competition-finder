//
//  PeteBJJCompFeedCacheIntegrationTests.swift
//  PeteBJJCompFeedCacheIntegrationTests
//
//  Created by Kobe Sam on 10/28/24.
//

import XCTest
import PeteBJJCompFeed

final class PeteBJJCompFeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(competitions):
                XCTAssertTrue(competitions.isEmpty, "Expected empty competitions")
                
            case let .failure(error):
                XCTFail("Expected successful competitions result, got \(error) instead")
            
            default:
                break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalCompetitionsLoader {
        let storeBundle = Bundle(for: CoreDataCompetitionsStore.self)
        let storeURL = testSpecificStoreURL()
        let store = CoreDataCompetitionsStore()
        let sut = LocalCompetitionsLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
