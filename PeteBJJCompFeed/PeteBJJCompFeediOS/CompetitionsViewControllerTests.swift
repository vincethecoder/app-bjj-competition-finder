//
//  CompetitionsViewControllerTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 11/1/24.
//

import XCTest

final class CompetitionsViewController: UIViewController {
    private var loader: CompetitionsViewControllerTests.LoaderSpy?
    
    convenience init(loader: CompetitionsViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

final class CompetitionsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadCompetitions() {
        let loader = LoaderSpy()
        _ = CompetitionsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = CompetitionsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }

}
