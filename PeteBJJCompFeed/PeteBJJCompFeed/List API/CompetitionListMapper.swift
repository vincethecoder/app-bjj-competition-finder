//
//  CompetitionListMapper.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/18/24.
//

import Foundation

enum CompetitionListMapper {
    private struct Root: Decodable {
        let competitions: [Competition]
    }
    
    private static var OK_200: Int { 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Competition] {
        guard response.statusCode == OK_200 else {
            throw RemoteCompetitionListLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).competitions
    }
}
