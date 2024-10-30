//
//  CompetitionsLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

public typealias LoadCompetitionsResult = Result<[Competition], Error>

public protocol CompetitionsLoader {
    func load(completion: @escaping (LoadCompetitionsResult) -> Void)
}
