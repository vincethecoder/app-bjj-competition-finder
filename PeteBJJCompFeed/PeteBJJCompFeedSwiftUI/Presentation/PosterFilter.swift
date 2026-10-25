//
//  PosterFilter.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

public struct PosterFilter: Identifiable, Equatable, Sendable {
    public typealias Criterion = CompetitionsScreen.Filter.Criterion

    public let id: String
    public let title: String
    public let criterion: Criterion

    public init(id: String, title: String, criterion: Criterion) {
        self.id = id
        self.title = title
        self.criterion = criterion
    }
}
