//
//  LoadCompetitionsFromCacheUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/22/24.
//

import XCTest
import PeteBJJCompFeed

class LoadCompetitionsFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        let retrievalError = anyNSError
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoCompetitionsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedCompetitionsOnNonExpiredCache() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge.adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(competitions.models)) {
            store.completeRetrieval(with: competitions.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoCachedCompetitionsOnCacheExpiration() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: competitions.local, timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoCachedCompetitionsOnExpiredCache() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge.adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: competitions.local, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedCompetitions])
    }
    
    func test_load_deleteNotDeleteCacheOnEmptyError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_deleteNotDeleteCacheOnNonExpiredCacheError() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge.adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: competitions.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_deletesCacheOnCacheExpirationError() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: competitions.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedCompetitions])
    }
    
    func test_load_deletesCacheOnExpiredCacheError() {
        let competitions = uniqueCompetitions
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusCompetitionsCacheMaxAge.adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: competitions.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedCompetitions])
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCompetitionsLoader, store: CompetitionsStoreSpy) {
        let store = CompetitionsStoreSpy()
        let sut = LocalCompetitionsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCompetitionsLoader, toCompleteWith expectedResult: LocalCompetitionsLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load competition")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedCompetitions), .success(expectedCompetitions)):
                XCTAssertEqual(receivedCompetitions, expectedCompetitions, file: file, line: line)
            
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            default:
                XCTFail("Expected result \(String(describing: expectedResult)), got \(String(describing: receivedResult)) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()

        wait(for: [exp], timeout: 1.0)
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private var anyURL: URL {
        URL(string: "http://any-url.com")!
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

private extension Date {
    
    var minusCompetitionsCacheMaxAge: Date {
        adding(days: -competitionsCacheMaxAgeInDays)
    }
    
    private var competitionsCacheMaxAgeInDays: Int { 7 }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
