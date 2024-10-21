//
//  CacheListUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/21/24.
//

import XCTest

class LocalListLoader {
    init(store: ListStore) {
        
    }
}

class ListStore {
    var deleteCachedListCallCount = 0
}

class CacheListUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = ListStore()
        _ = LocalListLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedListCallCount, 0)
    }
}
