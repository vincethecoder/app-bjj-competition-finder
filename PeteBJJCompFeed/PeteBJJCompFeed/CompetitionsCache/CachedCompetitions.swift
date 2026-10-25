//
//  CachedCompetitions.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// One cached snapshot. `screen` holds the encoded `CompetitionsScreen` the
/// server sent with these competitions, so offline launches show the same screen.
public struct CachedCompetitions {
    public let competitions: [LocalCompetition]
    public let screen: Data?
    public let timestamp: Date

    public init(competitions: [LocalCompetition], screen: Data? = nil, timestamp: Date) {
        self.competitions = competitions
        self.screen = screen
        self.timestamp = timestamp
    }
}
