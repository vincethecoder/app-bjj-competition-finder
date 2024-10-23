//
//  CodableCompetitionsStoreTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/23/24.
//

import XCTest
import PeteBJJCompFeed

final class CodableCompetitionStore {

    private struct Cache: Codable {
        let competitions: [CodableCompetition]
        let timestamp: Date
        
        var localCompetitions: [LocalCompetition] {
            competitions.map { $0.local }
        }
    }
    
    private struct CodableCompetition: Codable {
        private let id: String
        private let name: String
        private let startDate: Date
        private let endDate: Date
        private let venue: String
        private let city: String
        private let state: String?
        private let country: String
        private let type: CompetitionType
        private let status: CompetitionStatus
        private let registrationStatus: RegistrationStatus
        private let registrationLink: URL?
        private let eventLink: URL
        private let categories: [CompetitionCategory]
        private let rankingPoints: Int
        private let notes: String?
        
        init(_ competition: LocalCompetition) {
            self.id = competition.id
            self.name = competition.name
            self.startDate = competition.startDate
            self.endDate = competition.endDate
            self.venue = competition.venue
            self.city = competition.city
            self.state = competition.state
            self.country = competition.country
            self.type = competition.type
            self.status = competition.status
            self.registrationStatus = competition.registrationStatus
            self.registrationLink = competition.registrationLink
            self.eventLink = competition.eventLink
            self.categories = competition.categories
            self.rankingPoints = competition.rankingPoints
            self.notes = competition.notes
        }
        
        var local: LocalCompetition {
            LocalCompetition(id: id, name: name, startDate: startDate, endDate: startDate, venue: venue, city: city, state: state, country: country, type: type, status: status, registrationStatus: registrationStatus, registrationLink: registrationLink, eventLink: eventLink, categories: categories, rankingPoints: rankingPoints, notes: notes)
        }
        
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("competitions.store")
    
    func retrieve(completion: @escaping CompetitionsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(competitions: cache.localCompetitions, timestamp: cache.timestamp))
    }
    
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping CompetitionsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(competitions: competitions.map(CodableCompetition.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableCompetitionsStoreTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("competitions.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("competitions.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
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
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let competitions = uniqueCompetitions.local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(competitions, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected competitions to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let (.found(competitions: retrievedCompetitions, timestamp: retrievedTimestamp)):
                    XCTAssertEqual(retrievedCompetitions, competitions)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found result with competitions \(competitions) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableCompetitionStore {
        let sut = CodableCompetitionStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
