//
//  RemoteCompetitionsFeedLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Loads the competitions and the server-driven screen in one request.
public final class RemoteCompetitionsFeedLoader: CompetitionsFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = CompetitionsFeedLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func loadFeed(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(Result { try CompetitionsFeedMapper.map(data, from: response) })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
