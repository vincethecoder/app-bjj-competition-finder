//
//  XCTestCase+FailableDeleteCompetitionsStoreSpecs.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/26/24.
//

import XCTest
import PeteBJJCompFeed

extension FailableDeleteCompetitionsStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: CompetitionsStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)

            XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
        }

        func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: CompetitionsStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

            expect(sut, toRetrieve: .success(.none), file: file, line: line)
        }
}
