//
//  CompetitionListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

enum LoadCompetitionListResult {
    case succes([Competition])
    case error(Error)
}

protocol CompetitionListLoader {
    func load(completion: @escaping () -> Void)
}
