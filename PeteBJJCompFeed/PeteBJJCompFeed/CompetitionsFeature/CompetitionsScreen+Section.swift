//
//  CompetitionsScreen+Section.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen {
    public struct Section: Codable, Equatable, Identifiable, Sendable {
        public let id: String
        public let title: String
        public let cards: [Card]

        public init(id: String, title: String, cards: [Card]) {
            self.id = id
            self.title = title
            self.cards = cards
        }
    }
}
