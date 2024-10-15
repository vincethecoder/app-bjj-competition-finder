//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/14/24.
//

import XCTest

class RemoteCompetitionListLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteCompetitionListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        _ = RemoteCompetitionListLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionListLoader(url: url, client: client)
        
        sut.load()

        XCTAssertEqual(url, client.requestedURL)
    }
}
