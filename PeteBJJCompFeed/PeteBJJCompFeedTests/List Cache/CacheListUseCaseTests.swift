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
    
    init(store: ListStore) {
        self.store = store
    }
    
    func save(_ items: [Competition]) {
        store.deleteCachedList()
    }
}

class ListStore {
    var deleteCachedListCallCount = 0
    
    func deleteCachedList() {
        deleteCachedListCallCount += 1
    }
}

class CacheListUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedListCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedListCallCount, 1)
    }
    
    // MARK: - Helper
    
    private var uniqueItem: Competition {
        Competition(id: UUID().uuidString, name: "any-name", startDate: Date(), endDate: Date(), venue: "any-venue", city: "any-city", state: nil, country: "any-country", type: .gi, status: .upcoming, registrationStatus: .notOpen, registrationLink: nil, eventLink: anyURL, categories: [.adult], rankingPoints: 0, notes: nil)
    }
    
    private var anyURL: URL {
        URL(string: "http://any-url.com")!
    }
    
    private func makeSUT() -> (sut: LocalListLoader, store: ListStore) {
        let store = ListStore()
        let sut = LocalListLoader(store: store)
        return (sut, store)
    }
}
