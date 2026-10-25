//
//  PosterSection.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

public struct PosterSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let cards: [PosterCard]

    public init(id: String, title: String, cards: [PosterCard]) {
        self.id = id
        self.title = title
        self.cards = cards
    }
}
