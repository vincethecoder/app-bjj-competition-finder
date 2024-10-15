//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/14/24.
//

import XCTest

class RemoteCompetitionListLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()

    func get(from url: URL) {  }
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteCompetitionListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteCompetitionListLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteCompetitionListLoader()
        
        sut.load()

        XCTAssertNotNil(client.requestedURL)
    }
}
