//
//  SharedTestHelpers.swift
//  PeteBJJCompAppTests
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

func uniqueCompetition() -> Competition {
    Competition(
        id: UUID().uuidString,
        name: "any name",
        startDate: Date(timeIntervalSince1970: 1_717_027_200),
        endDate: Date(timeIntervalSince1970: 1_717_286_400),
        venue: "any venue",
        city: "any city",
        state: nil,
        country: "any country",
        type: .gi,
        status: .upcoming,
        registrationStatus: .open,
        registrationLink: nil,
        eventLink: anyURL,
        categories: [.adult],
        rankingPoints: 1000,
        notes: nil)
}
