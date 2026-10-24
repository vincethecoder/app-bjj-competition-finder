//
//  CompetitionsLoaderStub.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

final class CompetitionsLoaderStub: CompetitionsLoader {
    private let result: CompetitionsLoader.Result

    init(result: CompetitionsLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
        completion(result)
    }
}
