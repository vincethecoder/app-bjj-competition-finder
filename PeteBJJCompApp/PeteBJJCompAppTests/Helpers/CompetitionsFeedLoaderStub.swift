//
//  CompetitionsFeedLoaderStub.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsFeedLoaderStub: CompetitionsFeedLoader {
    private let result: CompetitionsFeedLoader.Result

    init(result: CompetitionsFeedLoader.Result) {
        self.result = result
    }

    func loadFeed(completion: @escaping (CompetitionsFeedLoader.Result) -> Void) {
        completion(result)
    }
}
