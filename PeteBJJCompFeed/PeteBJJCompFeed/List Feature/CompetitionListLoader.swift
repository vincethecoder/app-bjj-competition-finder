//
//  CompetitionListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

public enum LoadCompetitionListResult<Error: Swift.Error> {
    case success([Competition])
    case failure(Error)
}

extension LoadCompetitionListResult: Equatable where Error: Equatable {}

protocol CompetitionListLoader {
    associatedtype Error: Swift.Error

    func load(completion: @escaping (LoadCompetitionListResult<Error>) -> Void)
}
