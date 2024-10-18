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
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let competitions = try CompetitionListMapper.map(data, response)
                    completion(.success(competitions))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private enum CompetitionListMapper {
    private struct Root: Decodable {
        let competitions: [Competition]
    }
    
    static var OK_200: Int { 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Competition] {
        guard response.statusCode == OK_200 else {
            throw RemoteCompetitionListLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).competitions
    }
}

