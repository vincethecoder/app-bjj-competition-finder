//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/14/24.
//

import XCTest
import PeteBJJCompFeed

final class RemoteCompetitionListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()

        XCTAssertEqual(url, client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteCompetitionListLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionListLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
