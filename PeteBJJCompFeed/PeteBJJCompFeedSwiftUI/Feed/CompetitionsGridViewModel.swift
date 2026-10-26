//
//  CompetitionsGridViewModel.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Observation
import PeteBJJCompFeed

@MainActor
@Observable
public final class CompetitionsGridViewModel {
    /// Where the feed is in its load cycle. Each state carries the screen on
    /// display, so a reload or a failure never hides what was already shown.
    public enum State: Equatable {
        case idle
        case loading(screen: PosterScreen?)
        case loaded(screen: PosterScreen)
        /// The server couldn't be reached. The screen is the one already on
        /// display, or the cached one the fallback loaded instead.
        case failed(screen: PosterScreen?, message: LocalizedStringResource)
    }

    public private(set) var state: State = .idle
    public private(set) var selectedFilterID: PosterFilter.ID?
    /// The countries the location refinement offers, from the loaded events.
    public private(set) var countries: [String] = []

    /// The date, location and favorites the feed is narrowed to, kept across reloads.
    public var refinement = PosterRefinement()

    /// Shared with the detail screen, where events are starred.
    public let favorites: FavoriteCompetitions

    @ObservationIgnored private let loader: CompetitionsFeedLoader
    @ObservationIgnored private let locale: Locale
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date

    public init(
        loader: CompetitionsFeedLoader,
        favorites: FavoriteCompetitions,
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        now: @escaping () -> Date = Date.init
    ) {
        self.loader = loader
        self.favorites = favorites
        self.locale = locale
        self.calendar = calendar
        self.now = now
    }

    public var screen: PosterScreen? {
        switch state {
        case .idle: nil
        case let .loading(screen), let .failed(screen, _): screen
        case let .loaded(screen): screen
        }
    }

    public var isLoading: Bool {
        if case .loading = state { true } else { false }
    }

    public var errorMessage: LocalizedStringResource? {
        if case let .failed(_, message) = state { message } else { nil }
    }

    /// The screen's sections, keeping the cards that match the selected filter
    /// and the refinement. Computed on each read, so a favorite starred on the
    /// detail screen updates the feed through observation.
    public var visibleSections: [PosterSection] {
        guard let screen else { return [] }

        let refinement = refinement
        let favoriteIDs = favorites.ids
        let now = now()
        let calendar = calendar
        return screen.sections(filteredBy: selectedFilterID) {
            refinement.matches($0, favoriteIDs: favoriteIDs, now: now, calendar: calendar)
        }
    }

    /// Whether the screen has events but the selected filter or the refinement hides all of them,
    /// as opposed to a screen that has no events at all.
    public var isFilteredToNothing: Bool {
        screen?.sections.isEmpty == false && visibleSections.isEmpty
    }

    /// Whether the feed is narrowed to favorites but none of the screen's
    /// events is one, so the empty state can say how to add some.
    public var hasNoFavoritesToShow: Bool {
        guard refinement.favoritesOnly, let screen else { return false }

        return !screen.sections.contains { section in
            section.cards.contains { favorites.contains($0.id) }
        }
    }

    /// Loads the feed, keeping the current screen if loading fails.
    /// Calls made while a load is in flight are ignored.
    public func load() async {
        guard !isLoading else { return }

        let previousScreen = screen
        state = .loading(screen: previousScreen)

        do {
            let feed = try await loader.loadFeed()
            let newScreen = PosterScreenMapper.map(feed, locale: locale, calendar: calendar)
            show(newScreen)

            // The app reads the cache only when the server can't be reached, so a
            // cached feed is shown with the error that explains why it may be stale.
            state = feed.cachedAt == nil
                ? .loaded(screen: newScreen)
                : .failed(screen: newScreen, message: .feedViewConnectionError)
        } catch {
            state = .failed(screen: previousScreen, message: .feedViewConnectionError)
        }
    }

    public func selectFilter(_ id: PosterFilter.ID) {
        guard screen?.filters.contains(where: { $0.id == id }) == true else { return }

        selectedFilterID = id
    }

    /// Hides the error banner. With no screen to fall back to, the feed
    /// returns to idle and shows its empty state.
    public func dismissError() {
        guard case let .failed(screen, _) = state else { return }

        state = screen.map { .loaded(screen: $0) } ?? .idle
    }

    /// Readies the filter and refinement for a new screen, keeping the selected
    /// filter when the new screen still offers it, and selecting the first filter
    /// otherwise. A country the new screen has no events in is cleared.
    private func show(_ newScreen: PosterScreen) {
        if !newScreen.filters.contains(where: { $0.id == selectedFilterID }) {
            selectedFilterID = newScreen.filters.first?.id
        }

        countries = newScreen.countries(locale: locale)
        if let country = refinement.country, !countries.contains(country) {
            refinement.country = nil
        }
    }
}
