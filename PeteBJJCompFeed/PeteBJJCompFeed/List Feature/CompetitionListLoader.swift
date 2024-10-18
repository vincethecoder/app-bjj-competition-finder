//
//  CompetitionListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

public enum LoadCompetitionListResult {
    case success([Competition])
    case failure(Error)
}

protocol CompetitionListLoader {
    func load(completion: @escaping (LoadCompetitionListResult) -> Void)
}
