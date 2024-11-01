//
//  CompetitionsViewControllerTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 11/1/24.
//

import XCTest
import PeteBJJCompFeed

final class CompetitionsViewController: UIViewController {
    private var loader: CompetitionsLoader?
    
    convenience init(loader: CompetitionsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
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
    
    class LoaderSpy: CompetitionsLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }

}
