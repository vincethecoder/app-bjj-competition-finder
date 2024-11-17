//
//  MainQueueDispatchDecorator.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import Foundation
import PeteBJJCompFeed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: CompetitionsLoader where T == CompetitionsLoader {
    func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: EventImageDataLoader where T == EventImageDataLoader {
    func loadImageData(from url: URL, completition: @escaping (EventImageDataLoader.Result) -> Void) -> any EventImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completition(result) }
        }
    }
}
