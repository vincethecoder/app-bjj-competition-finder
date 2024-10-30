//
//  XCTestCase+FailableRetrieveCompetitionsStoreSpecs.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/26/24.
//

import XCTest
import PeteBJJCompFeed

extension FailableRetrieveCompetitionsStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: CompetitionsStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: CompetitionsStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError), file: file, line: line)
    }
}
