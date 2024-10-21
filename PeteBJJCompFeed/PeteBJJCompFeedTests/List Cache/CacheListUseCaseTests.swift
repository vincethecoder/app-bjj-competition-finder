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
        let store = ListStore()
        _ = LocalListLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedListCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = ListStore()
        let sut = LocalListLoader(store: store)
        let items = [uniqueItem, uniqueItem]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedListCallCount, 1)
    }
    
    // MARK: - Helper
    
    private var uniqueItem: Competition {
        Competition(id: UUID().uuidString, name: "any-name", startDate: Date(), endDate: Date(), venue: "any-venue", city: "any-city", state: nil, country: "any-country", type: .gi, status: .upcoming, registrationStatus: .notOpen, registrationLink: nil, eventLink: URL(string: "https://any-event-link.com")!, categories: [.adult], rankingPoints: 0, notes: nil)
    }
    
}
