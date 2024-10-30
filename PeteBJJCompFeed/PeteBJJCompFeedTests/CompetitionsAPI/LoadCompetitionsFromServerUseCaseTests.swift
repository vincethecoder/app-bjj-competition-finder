//
//  LoadCompetitionsFromServerUseCaseTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/14/24.
//

import XCTest
import PeteBJJCompFeed

final class LoadCompetitionsFromServerUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeCompetitionsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoCompetitionsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeCompetitionsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversCompetitionsOn200HTTPResponseWithJSONCompetitions() {
        let (sut, client) = makeSUT()

        let competition1 = makeCompetition(
            id: UUID(),
            name: "World IBJJF Jiu-Jitsu Championship - CA",
            startDateString: "2024-05-30",
            endDateString: "2024-06-02",
            venue: "The Walter Pyramid (CSULB)",
            city: "Long Beach",
            state: "CA",
            country: "USA",
            type: .gi,
            status: .upcoming,
            registrationStatus: .open,
            registrationLink: URL(string: "http://a-url.com/events/registration")!,
            eventLink: URL(string: "http://a-url.com/events/jiu-jitsu-championship")!,
            categories: [.adult, .master],
            rankingPoints: 1000,
            notes: "63 ranking points required for Black belt division.")
        
        let competition2 = makeCompetition(
            id: UUID(),
            name: "World IBJJF Jiu-Jitsu Championship - TX",
            startDateString: "2024-11-01",
            endDateString: "2024-11-03",
            venue: "Fort Worth Convention Center & Arena",
            city: "Fort Worth",
            state: "TX",
            country: "USA",
            type: .nogi,
            status: .upcoming,
            registrationStatus: .notOpen,
            eventLink: URL(string: "http://a-url.com/events/jiu-jitsu-championship")!,
            categories: [.juvenile, .adult, .master],
            rankingPoints: 750)

        let competitions = [competition1.model, competition2.model]
        
        expect(sut, toCompleteWith: .success(competitions), when: {
            let json = makeCompetitionsJSON([competition1.json, competition2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteCompetitionsLoader? = RemoteCompetitionsLoader(url: url, client: client)

        var capturedResults = [RemoteCompetitionsLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeCompetitionsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
 
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCompetitionsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionsLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteCompetitionsLoader.Error) -> RemoteCompetitionsLoader.Result {
        return .failure(error)
    }
    
    private func makeCompetition(id: UUID, name: String, startDateString: String, endDateString: String, venue: String, city: String, state: String? = nil, country: String, type: CompetitionType, status: CompetitionStatus, registrationStatus: RegistrationStatus, registrationLink: URL? = nil, eventLink: URL, categories: [CompetitionCategory], rankingPoints: Int, notes: String? = nil) -> (model: Competition, json: [String: Any]) {
        
        let model = Competition(id: id.uuidString, name: name, startDate: Date.dateFromString(startDateString), endDate: Date.dateFromString(endDateString), venue: venue, city: city, state: state, country: country, type: type, status: status, registrationStatus: registrationStatus, registrationLink: registrationLink, eventLink: eventLink, categories: categories, rankingPoints: rankingPoints, notes: notes)
        
        let json = [
            "id": model.id,
            "name": model.name,
            "startDate": startDateString,
            "endDate": endDateString,
            "venue": model.venue,
            "city": model.city,
            "state": model.state as Any,
            "country": model.country,
            "type": model.type.rawValue,
            "status": model.status.rawValue,
            "registrationStatus": model.registrationStatus.rawValue,
            "registrationLink": model.registrationLink?.absoluteString as Any,
            "eventLink": model.eventLink.absoluteString,
            "categories": model.categories.map { $0.rawValue },
            "rankingPoints": model.rankingPoints,
            "notes": model.notes as Any
        ].compactMapValues { $0 } as [String: Any]

        return (model, json)
    }
    
    private func expect(_ sut: RemoteCompetitionsLoader, toCompleteWith expectedResult: RemoteCompetitionsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedCompetitions), .success(expectedCompetitions)):
                XCTAssertEqual(receivedCompetitions, expectedCompetitions, file: file, line: line)
                
            case let (.failure(receivedError as RemoteCompetitionsLoader.Error), .failure(expectedError as RemoteCompetitionsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            default:
                XCTFail("Expected Result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            self.messages.map { $0.url }
        }
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
