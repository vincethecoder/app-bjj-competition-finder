//
//  CacheListUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/21/24.
//

import XCTest
import PeteBJJCompFeed

class LocalListLoader {
    private let store: ListStore
    private let currentDate: () -> Date
    
    init(store: ListStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [Competition]) {
        store.deleteCachedList { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class ListStore {
    typealias DeletionCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
        case deleteCachedList
        case insert([Competition], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedList(compeletion: @escaping (Error?) -> Void) {
        deletionCompletions.append(compeletion)
        receivedMessages.append(.deleteCachedList)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [Competition], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheListUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedList])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        let deletionError = anyNSError
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedList])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem, uniqueItem]

        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedList, .insert(items, timestamp)])
    }
    
    // MARK: - Helper
    
    private var uniqueItem: Competition {
        Competition(id: UUID().uuidString, name: "any-name", startDate: Date(), endDate: Date(), venue: "any-venue", city: "any-city", state: nil, country: "any-country", type: .gi, status: .upcoming, registrationStatus: .notOpen, registrationLink: nil, eventLink: anyURL, categories: [.adult], rankingPoints: 0, notes: nil)
    }
    
    private var anyURL: URL {
        URL(string: "http://any-url.com")!
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalListLoader, store: ListStore) {
        let store = ListStore()
        let sut = LocalListLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
