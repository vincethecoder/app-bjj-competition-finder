//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/15/24.
//

import Foundation

public final class RemoteCompetitionListLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([Competition])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(data, response):
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let competitions = try CompetitionListMapper.map(data, response)
            return .success(competitions)
        } catch {
            return .failure(.invalidData)
        }
    }
}
