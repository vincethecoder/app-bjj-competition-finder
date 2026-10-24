//
//  SharedTestHelpers.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyURL: URL {
    URL(string: "http://any-url.com")!
}

func uniqueCompetitions() -> [Competition] {
    [uniqueCompetition(), uniqueCompetition()]
}

func uniqueCompetition(
    startDate: Date = Date(timeIntervalSince1970: 1_717_027_200),
    endDate: Date = Date(timeIntervalSince1970: 1_717_286_400),
    venue: String = "Walter Pyramid",
    city: String = "Long Beach",
    state: String? = "CA"
) -> Competition {
    Competition(
        id: UUID().uuidString,
        name: "World IBJJF Jiu-Jitsu Championship",
        startDate: startDate,
        endDate: endDate,
        venue: venue,
        city: city,
        state: state,
        country: "USA",
        type: .gi,
        status: .upcoming,
        registrationStatus: .open,
        registrationLink: nil,
        eventLink: anyURL,
        categories: [.adult],
        rankingPoints: 1000,
        notes: nil)
}
