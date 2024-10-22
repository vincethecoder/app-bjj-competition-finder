//
//  RemoteCompetitionsLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/15/24.
//

import Foundation

public final class RemoteCompetitionsLoader: CompetitionsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadCompetitionsResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success(data, response):
                completion(Self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let competitions = try CompetitionsMapper.map(data, from: response)
            return .success(competitions.mapped)
        } catch {
            return .failure(error)
        }
    }
}
