//
//  CompetitionsUIIntegrationTests+Assertions.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import XCTest
import PeteBJJCompFeed
import PeteBJJCompFeediOS

extension CompetitionsUIIntegrationTests {
    
    func assertThat(_ sut: CompetitionsViewController, isRendering competitions: [Competition], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedCompetitionViews() == competitions.count else {
            return XCTFail("Expected \(competitions.count) events, got \(sut.numberOfRenderedCompetitionViews()) instead.", file: file, line: line)
        }
        
        competitions.enumerated().forEach { index, event in
            assertThat(sut, hasViewConfiguredFor: event, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: CompetitionsViewController, hasViewConfiguredFor competition: Competition, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.competitionsView(at: index)
        
        guard let cell = view as? CompetitionsCell else {
            return XCTFail("Expected \(CompetitionsCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let event = competition.toCompetitiveEvent()
        XCTAssertEqual(cell.dateText, event.date, "Expected date text to be \(event.date) for competition view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.eventText, event.name, "Expected name text to be \(event.name) for competition view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.venueText, event.venue, "Expected venue text to be \(event.venue) for competition view at index (\(index))", file: file, line: line)
    }
}
