//
//  CompetitionsFeedLoader+TestHelpers.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed

func expect(_ sut: CompetitionsFeedLoader, toCompleteWith expectedResult: CompetitionsFeedLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) {
    var receivedResult: CompetitionsFeedLoader.Result?
    sut.loadFeed { receivedResult = $0 }

    switch (receivedResult, expectedResult) {
    case let (.success(receivedFeed)?, .success(expectedFeed)):
        #expect(receivedFeed == expectedFeed, sourceLocation: sourceLocation)

    case let (.failure(receivedError as NSError)?, .failure(expectedError as NSError)):
        #expect(receivedError == expectedError, sourceLocation: sourceLocation)

    default:
        Issue.record("Expected \(expectedResult), got \(String(describing: receivedResult)) instead", sourceLocation: sourceLocation)
    }
}
