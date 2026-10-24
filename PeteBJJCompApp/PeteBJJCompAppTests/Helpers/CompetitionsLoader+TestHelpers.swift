//
//  CompetitionsLoader+TestHelpers.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed

func expect(_ sut: CompetitionsLoader, toCompleteWith expectedResult: CompetitionsLoader.Result, sourceLocation: SourceLocation = #_sourceLocation) {
    var receivedResult: CompetitionsLoader.Result?
    sut.load { receivedResult = $0 }

    switch (receivedResult, expectedResult) {
    case let (.success(receivedCompetitions)?, .success(expectedCompetitions)):
        #expect(receivedCompetitions == expectedCompetitions, sourceLocation: sourceLocation)

    case let (.failure(receivedError as NSError)?, .failure(expectedError as NSError)):
        #expect(receivedError == expectedError, sourceLocation: sourceLocation)

    default:
        Issue.record("Expected \(expectedResult), got \(String(describing: receivedResult)) instead", sourceLocation: sourceLocation)
    }
}
