//
//  CompetitionsLoaderCacheDecorator.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsLoaderCacheDecorator: CompetitionsLoader {
    private let decoratee: CompetitionsLoader
    private let cache: CompetitionsCache

    init(decoratee: CompetitionsLoader, cache: CompetitionsCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { competitions in
                self?.cache.saveIgnoringResult(competitions)
                return competitions
            })
        }
    }
}

private extension CompetitionsCache {
    // A failed save shouldn't fail the load: the competitions are still fresh,
    // and the fallback cache keeps its previous contents.
    func saveIgnoringResult(_ competitions: [Competition]) {
        save(competitions) { _ in }
    }
}
