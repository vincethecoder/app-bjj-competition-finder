//
//  CompetitionsLoader.swift
//  PeteBJJCompFeed
//
//  Created by Vince K. Sam on 10/14/24.
//

import Foundation

public protocol CompetitionsLoader {
    typealias Result = Swift.Result<[Competition], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
