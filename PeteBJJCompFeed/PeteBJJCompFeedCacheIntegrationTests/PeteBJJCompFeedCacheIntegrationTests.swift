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
        
        expect(sut, toLoad: [])
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalCompetitionsLoader {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let store = try! CoreDataCompetitionsStore(storeURL: storeURL)
        let sut = LocalCompetitionsLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalCompetitionsLoader, toLoad expectedCompetitions: [Competition], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(competitions):
                XCTAssertTrue(competitions.isEmpty, "Expected empty competitions")
                
            case let .failure(error):
                XCTFail("Expected successful competitions result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private var uniqueCompetition: Competition {
        Competition(id: UUID().uuidString, name: "any-name", startDate: Date(), endDate: Date(), venue: "any-venue", city: "any-city", state: nil, country: "any-country", type: .gi, status: .upcoming, registrationStatus: .notOpen, registrationLink: nil, eventLink: anyURL, categories: [.adult], rankingPoints: 0, notes: nil)
    }
    
    private var uniqueCompetitions: (models: [Competition], local: [LocalCompetition]) {
        let models = [uniqueCompetition, uniqueCompetition]
        let localCompetitions = models.map {
            LocalCompetition(id: $0.id, name: $0.name, startDate: $0.startDate, endDate: $0.endDate, venue: $0.venue, city: $0.city, state: $0.state, country: $0.country, type: $0.type, status: $0.status, registrationStatus: $0.registrationStatus, registrationLink: $0.registrationLink, eventLink: $0.eventLink, categories: $0.categories, rankingPoints: $0.rankingPoints, notes: $0.notes)
        }
        return (models, localCompetitions)
    }
}
