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
                client.complete(withStatusCode: code, at: index)
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
            let emptyListJSON = Data("{\"competitions\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = Competition(
            id: UUID(),
            name: "World IBJJF Jiu-Jitsu Championship - CA",
            startDate: Date.dateFromString("2024-05-30"),
            endDate: Date.dateFromString("2024-06-02"),
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
       
        let item1JSON = [
            "id": item1.id.uuidString,
            "name": item1.name,
            "startDate": item1.startDate.timeIntervalSinceReferenceDate,
            "endDate": item1.endDate.timeIntervalSinceReferenceDate,
            "venue": item1.venue,
            "city": item1.city,
            "state": item1.state!,
            "country": item1.country,
            "type": item1.type.rawValue,
            "status": item1.status.rawValue,
            "registrationStatus": item1.registrationStatus.rawValue,
            "registrationLink": item1.registrationLink!.absoluteString,
            "eventLink": item1.eventLink.absoluteString,
            "categories": item1.categories.map { $0.rawValue },
            "rankingPoints": item1.rankingPoints,
            "notes": item1.notes!
        ] as [String : Any]
        
        let item2 = Competition(
            id: UUID(),
            name: "World IBJJF Jiu-Jitsu Championship - TX",
            startDate: Date.dateFromString("2024-11-01"),
            endDate: Date.dateFromString("2024-11-03"),
            venue: "Fort Worth Convention Center & Arena",
            city: "Fort Worth",
            state: "TX",
            country: "USA",
            type: .nogi,
            status: .upcoming,
            registrationStatus: .notOpen,
            registrationLink: nil,
            eventLink: URL(string: "http://a-url.com/events/jiu-jitsu-championship")!,
            categories: [.juvenile, .adult, .master],
            rankingPoints: 750, notes: nil)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "name": item2.name,
            "startDate": item2.startDate.timeIntervalSinceReferenceDate,
            "endDate": item2.endDate.timeIntervalSinceReferenceDate,
            "venue": item2.venue,
            "city": item2.city,
            "state": item2.state!,
            "country": item2.country,
            "type": item2.type.rawValue,
            "status": item2.status.rawValue,
            "registrationStatus": item2.registrationStatus.rawValue,
            "eventLink": item2.eventLink.absoluteString,
            "categories": item2.categories.map { $0.rawValue },
            "rankingPoints": item2.rankingPoints
        ] as [String : Any]
        
        let itemsJSON = [
            "competitions": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        })
    }
 
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteCompetitionListLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCompetitionListLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteCompetitionListLoader, toCompleteWith result: RemoteCompetitionListLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteCompetitionListLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
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
