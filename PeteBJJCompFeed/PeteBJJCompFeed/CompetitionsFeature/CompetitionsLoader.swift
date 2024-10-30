//
//  CompetitionsLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

public enum LoadCompetitionsResult {
    case success([Competition])
    case failure(Error)
}

public protocol CompetitionsLoader {
    func load(completion: @escaping (LoadCompetitionsResult) -> Void)
}
