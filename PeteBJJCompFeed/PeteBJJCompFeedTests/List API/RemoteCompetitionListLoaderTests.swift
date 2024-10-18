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
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(
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
        
        let item2 = makeItem(
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

        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteCompetitionListLoader? = RemoteCompetitionListLoader(url: url, client: client)

        var capturedResults = [RemoteCompetitionListLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }
 
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCompetitionListLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionListLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID, name: String, startDateString: String, endDateString: String, venue: String, city: String, state: String? = nil, country: String, type: CompetitionType, status: CompetitionStatus, registrationStatus: RegistrationStatus, registrationLink: URL? = nil, eventLink: URL, categories: [CompetitionCategory], rankingPoints: Int, notes: String? = nil) -> (model: Competition, json: [String: Any]) {
        
        let model = Competition(id: id, name: name, startDate: Date.dateFromString(startDateString), endDate: Date.dateFromString(endDateString), venue: venue, city: city, state: state, country: country, type: type, status: status, registrationStatus: registrationStatus, registrationLink: registrationLink, eventLink: eventLink, categories: categories, rankingPoints: rankingPoints, notes: notes)
        
        let json = [
            "id": model.id.uuidString,
            "name": model.name,
            "startDate": model.startDate.timeIntervalSinceReferenceDate,
            "endDate": model.endDate.timeIntervalSinceReferenceDate,
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
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["competitions": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteCompetitionListLoader, toCompleteWith expectedResult: RemoteCompetitionListLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
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

private extension Date {
    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("invalid date from dateString: \(dateString)")
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let _year = components.year,
              let _month = components.month,
              let _day = components.day else {
            fatalError("invalid components dateString: \(dateString)")
        }
        
        return Calendar.current.date(from: DateComponents(year: _year, month: _month, day: _day))!
    }
}
