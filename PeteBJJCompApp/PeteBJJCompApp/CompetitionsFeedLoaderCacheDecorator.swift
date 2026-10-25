//
//  CompetitionsFeedLoaderCacheDecorator.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsFeedLoaderCacheDecorator: CompetitionsFeedLoader {
    private let decoratee: CompetitionsFeedLoader
    private let cache: CompetitionsFeedCache

    init(decoratee: CompetitionsFeedLoader, cache: CompetitionsFeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func loadFeed(completion: @escaping (CompetitionsFeedLoader.Result) -> Void) {
        decoratee.loadFeed { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension CompetitionsFeedCache {
    // A failed save shouldn't fail the load: the feed is still fresh,
    // and the fallback cache keeps its previous contents.
    func saveIgnoringResult(_ feed: CompetitionsFeed) {
        save(feed) { _ in }
    }
}
