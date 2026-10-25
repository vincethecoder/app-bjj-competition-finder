//
//  CompetitionsFeed.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// One snapshot of the feed: the competitions, plus the server-driven screen
/// that presents them, when the server sent one.
public struct CompetitionsFeed: Equatable, Sendable {
    public let competitions: [Competition]
    public let screen: CompetitionsScreen?

    /// When this snapshot was saved, if it was loaded from the cache;
    /// `nil` when it came straight from the server.
    public let cachedAt: Date?

    public init(competitions: [Competition], screen: CompetitionsScreen?, cachedAt: Date? = nil) {
        self.competitions = competitions
        self.screen = screen
        self.cachedAt = cachedAt
    }
}
