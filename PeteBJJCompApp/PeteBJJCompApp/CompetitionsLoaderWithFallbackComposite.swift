//
//  CompetitionsLoaderWithFallbackComposite.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsLoaderWithFallbackComposite: CompetitionsLoader {
    private let primary: CompetitionsLoader
    private let fallback: CompetitionsLoader

    init(primary: CompetitionsLoader, fallback: CompetitionsLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
