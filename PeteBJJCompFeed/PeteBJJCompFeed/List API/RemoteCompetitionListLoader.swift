//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/15/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteCompetitionListLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() {
        client.get(from: url)
    }
}
