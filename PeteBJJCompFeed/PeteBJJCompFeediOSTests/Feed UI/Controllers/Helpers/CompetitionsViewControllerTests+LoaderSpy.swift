//
//  CompetitionsViewControllerTests+LoaderSpy.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import Foundation
import PeteBJJCompFeed
import PeteBJJCompFeediOS

extension CompetitionsViewControllerTests {
    
    class LoaderSpy: CompetitionsLoader, EventImageDataLoader {
        
        // MARK: - CompetitionsLoader
        
        private var competitionsRequests = [(CompetitionsLoader.Result) -> Void]()
        
        var loadCompetitionsCallCount: Int {
            competitionsRequests.count
        }
        
        func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
            competitionsRequests.append(completion)
        }
        
        func completeFeedLoading(with events: [Competition] = [], at index: Int = 0) {
            competitionsRequests[index](.success(events))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = anyNSError
            competitionsRequests[index](.failure(error))
        }
        
        private struct TaskSpy: EventImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completition: (EventImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completition: @escaping (EventImageDataLoader.Result) -> Void) -> any EventImageDataLoaderTask {
            imageRequests.append((url, completition))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completition(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = anyNSError
            imageRequests[index].completition(.failure(error))
        }
    }
}
