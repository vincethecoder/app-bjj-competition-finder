//
//  RemoteCompetitionListLoader.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/14/24.
//

import XCTest

class RemoteCompetitionListLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteCompetitionListLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteCompetitionListLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
