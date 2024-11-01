//
//  CompetitionsViewControllerTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 11/1/24.
//

import XCTest

final class CompetitionsViewController {
    init(loader: CompetitionsViewControllerTests.LoaderSpy) {
        
    }
}

final class CompetitionsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadCompetitions() {
        let loader = LoaderSpy()
        _ = CompetitionsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }

}
