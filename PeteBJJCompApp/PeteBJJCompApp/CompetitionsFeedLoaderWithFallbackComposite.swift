//
//  CompetitionsFeedLoaderWithFallbackComposite.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsFeedLoaderWithFallbackComposite: CompetitionsFeedLoader {
    private let primary: CompetitionsFeedLoader
    private let fallback: CompetitionsFeedLoader

    init(primary: CompetitionsFeedLoader, fallback: CompetitionsFeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func loadFeed(completion: @escaping (CompetitionsFeedLoader.Result) -> Void) {
        primary.loadFeed { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                self?.fallback.loadFeed(completion: completion)
            }
        }
    }
}
