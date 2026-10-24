//
//  CompetitionsScreen.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// What the server wants the feed to show, and in which order.
/// Clients decide how to draw it. It's `Codable` so the cache can store it
/// alongside the competitions it presents.
public struct CompetitionsScreen: Codable, Equatable, Sendable {
    public let title: String?
    public let empty: EmptyState?
    public let filters: [Filter]
    public let sections: [Section]

    public init(title: String?, empty: EmptyState?, filters: [Filter], sections: [Section]) {
        self.title = title
        self.empty = empty
        self.filters = filters
        self.sections = sections
    }
}
