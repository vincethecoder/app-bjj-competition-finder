//
//  SharedTestHelpers.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/26/24.
//

import Foundation

var anyURL: URL {
    URL(string: "http://any-url.com")!
}

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyData: Data {
    Data("any data".utf8)
}

var anyHTTPURLResponse: HTTPURLResponse {
    HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

var nonHTTPURLResponse: URLResponse {
    URLResponse(url: anyURL, mimeType: nil, expectedContentLength: .zero, textEncodingName: nil)
}

func makeCompetitionsJSON(_ competitions: [[String: Any]]) -> Data {
    let json = ["competitions": competitions]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    
    var minusCompetitionsCacheMaxAge: Date {
        adding(days: -competitionsCacheMaxAgeInDays)
    }
    
    private var competitionsCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
