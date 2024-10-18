//
//  URLSessionHTTPClientTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/18/24.
//

import XCTest
import PeteBJJCompFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_cresumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)

        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError(){
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)

        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private final class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private final class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() { }
    }
    private final class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
        
    }
}
