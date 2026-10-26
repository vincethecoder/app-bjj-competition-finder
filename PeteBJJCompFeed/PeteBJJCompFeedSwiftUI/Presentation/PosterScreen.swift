//
//  PosterScreen.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Everything the grid draws, with copy resolved and dates formatted.
public struct PosterScreen: Equatable, Sendable {
    public let title: String
    public let emptyTitle: String
    public let emptyMessage: String
    public let filters: [PosterFilter]
    public let sections: [PosterSection]

    public init(title: String, emptyTitle: String, emptyMessage: String, filters: [PosterFilter], sections: [PosterSection]) {
        self.title = title
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.filters = filters
        self.sections = sections
    }

    /// The sections, keeping only the cards the filter matches and that
    /// `isIncluded` accepts. Sections left without cards are dropped. An
    /// unknown or `nil` filter matches every card.
    public func sections(filteredBy filterID: PosterFilter.ID?, where isIncluded: (PosterCard) -> Bool = { _ in true }) -> [PosterSection] {
        let criterion = filters.first(where: { $0.id == filterID })?.criterion ?? .all

        return sections.compactMap { section in
            let cards = section.cards.filter { $0.matches(criterion) && isIncluded($0) }
            return cards.isEmpty ? nil : PosterSection(id: section.id, title: section.title, cards: cards)
        }
    }

    /// Every country with an event on the screen, in alphabetical order.
    public func countries(locale: Locale) -> [String] {
        Set(sections.lazy.flatMap(\.cards).compactMap(\.country))
            .sorted { $0.compare($1, options: [.caseInsensitive, .diacriticInsensitive], locale: locale) == .orderedAscending }
    }
}
