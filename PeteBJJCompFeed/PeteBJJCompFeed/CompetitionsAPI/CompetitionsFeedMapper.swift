//
//  CompetitionsFeedMapper.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

enum CompetitionsFeedMapper {
    private struct Root: Decodable {
        let competitions: [RemoteCompetition]
        let screen: RemoteCompetitionsScreen?

        private enum CodingKeys: String, CodingKey {
            case competitions, screen
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            competitions = try container.decode([RemoteCompetition].self, forKey: .competitions)
            // Clients build an equivalent screen from the competitions, so a
            // screen the app can't read degrades to that instead of failing the load.
            screen = (try? container.decodeIfPresent(RemoteCompetitionsScreen.self, forKey: .screen)) ?? nil
        }
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> CompetitionsFeed {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteCompetitionsFeedLoader.Error.invalidData
        }

        return CompetitionsFeed(competitions: root.competitions.mapped, screen: root.screen?.model)
    }
}
