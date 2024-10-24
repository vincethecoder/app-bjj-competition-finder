//
//  CodableCompetitionsStoreTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/23/24.
//

import XCTest
import PeteBJJCompFeed

final class CodableCompetitionStore: CompetitionsStore {

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
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(competitions: cache.localCompetitions, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping CompetitionsStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(competitions: competitions.map(CodableCompetition.init), timestamp: timestamp)
            let encoded = try! encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteCachedCompetitions(completion: DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

final class CodableCompetitionsStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let competitions = uniqueCompetitions.local
        let timestamp = Date()

        insert((competitions, timestamp), to: sut)

        expect(sut, toRetrieve: .found(competitions: competitions, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let competitions = uniqueCompetitions.local
        let timestamp = Date()
        
        insert((competitions, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(competitions: competitions, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueCompetitions.local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestCompetitions = uniqueCompetitions.local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestCompetitions, latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(competitions: latestCompetitions, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let competitions = uniqueCompetitions.local
        let timestamp = Date()
        
        let insertionError = insert((competitions, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache deletion")
        
        sut.deleteCachedCompetitions { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueCompetitions.local, Date()), to: sut)
        

        let deletionError = deleteCache(from: sut)
    
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CompetitionsStore {
        let sut = CodableCompetitionStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (competition: [LocalCompetition], timestamp: Date), to sut: CompetitionsStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.competition, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func deleteCache(from sut: CompetitionsStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedCompetitions { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func expect(_ sut: CompetitionsStore, toRetrieveTwice expectedResult: RetrieveCachedCompetitionResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CompetitionsStore, toRetrieve expectedResult: RetrieveCachedCompetitionResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    
    private var testSpecificStoreURL: URL {
        cachesDirectory.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private var anyURL: URL {
        URL(string: "http://any-url.com")!
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
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
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
}
