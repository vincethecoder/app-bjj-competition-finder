//
//  PeteBJJCompFeedAPIEndToEndTests.swift
//  PeteBJJCompFeedAPIEndToEndTests
//
//  Created by Kobe Sam on 10/20/24.
//

import XCTest
import PeteBJJCompFeed

final class PeteBJJCompFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        let competitionListResult = getCompetitionListResult()
        switch competitionListResult {
        case let .success(competitions):
            XCTAssertEqual(competitions.count, 4, "Expected 4 items in the test account feed")
            XCTAssertEqual(competitions[0], expectedCompetition(at: 0))
            XCTAssertEqual(competitions[1], expectedCompetition(at: 1))
            XCTAssertEqual(competitions[2], expectedCompetition(at: 2))
            XCTAssertEqual(competitions[3], expectedCompetition(at: 3))

        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getCompetitionListResult(file: StaticString = #filePath, line: UInt = #line) -> LoadCompetitionListResult? {
        let testServerURL = URL(string: "https://bit.ly/4hd1liM")!
        let client = URLSessionHTTPClient()
        let loader = RemoteCompetitionListLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadCompetitionListResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedCompetition(at index: Int) -> Competition {
        return Competition(
            id: id(at: index),
            name: name(at: index),
            startDate: someStartDate,
            endDate: someEndDate,
            venue: venue(at: index),
            city: city(at: index),
            state: state(at: index),
            country: country(at: index),
            type: type(at: index),
            status: competitionStatus(at: index),
            registrationStatus: registrationStatus(at: index),
            registrationLink: registrationLink(at: index),
            eventLink: eventLink(at: index),
            categories: categories(at: index),
            rankingPoints: rankingPoints(at: index),
            notes: notes (at: index))
    }

    private func id(at index: Int) -> String {
        return "ibjjf-2024-00\(index+1)"
    }
    
    private func name(at index: Int) -> String {
        return "World IBJJF Jiu-Jitsu Championship 2024 - 0\(index+1)"
    }
    
    private var someStartDate: Date {
        Date.dateFromString("2024-05-30")
    }
    
    private var someEndDate: Date {
        Date.dateFromString("2024-06-02")
    }
    
    private func text(for key: String, at index: Int) -> String {
        return "\(key)-\(index+1)"
    }
    
    private func venue(at index: Int) -> String {
        return text(for: "venue", at: index)
    }
    
    private func city(at index: Int) -> String {
        return text(for: "city", at: index)
    }
    
    private func state(at index: Int) -> String? {
        return text(for: "state", at: index)
    }
    
    private func country(at index: Int) -> String {
        return text(for: "country", at: index)
    }
    
    private func registrationLink(at index: Int) -> URL {
        return URL(string: "https:\\registration-url-\(index+1).com")!
    }
    
    private func eventLink(at index: Int) -> URL {
        return URL(string: "https:\\event-url-\(index+1).com")!
    }
    
    private func rankingPoints(at index: Int) -> Int {
        return  1000 + index + 1
    }
    
    private func notes (at index: Int) -> String {
        return text(for: "notes", at: index)
    }

    private func categories(at index: Int) -> [CompetitionCategory] {
        return [
            [.adult, .master],
            [.juvenile],
            [.kids],
            [.master]
        ][index]
    }
    
    private func type(at index: Int) -> CompetitionType {
        return [
            .gi,
            .nogi,
            .nogi,
            .nogi
        ][index]
    }
    
    func competitionStatus(at index: Int) -> CompetitionStatus {
        return [
            .upcoming,
            .ongoing,
            .ongoing,
            .ongoing
        ][index]
    }
    
    private func registrationStatus(at index: Int) -> RegistrationStatus {
        return [
            .open,
            .invitationOnly,
            .open,
            .notOpen
        ][index]
    }
}
