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
    public private(set) var visibleSections: [PosterSection] = []

    @ObservationIgnored private let loader: CompetitionsFeedLoader
    @ObservationIgnored private let locale: Locale
    @ObservationIgnored private let calendar: Calendar

    public init(loader: CompetitionsFeedLoader, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent) {
        self.loader = loader
        self.locale = locale
        self.calendar = calendar
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

    /// Whether the screen has events but the selected filter hides all of them,
    /// as opposed to a screen that has no events at all.
    public var isFilteredToNothing: Bool {
        screen?.sections.isEmpty == false && visibleSections.isEmpty
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
        visibleSections = screen?.sections(filteredBy: id) ?? []
    }

    /// Hides the error banner. With no screen to fall back to, the feed
    /// returns to idle and shows its empty state.
    public func dismissError() {
        guard case let .failed(screen, _) = state else { return }

        state = screen.map { .loaded(screen: $0) } ?? .idle
    }

    /// Shows the sections of a new screen, keeping the selected filter when the
    /// new screen still offers it, and selecting the first filter otherwise.
    private func show(_ newScreen: PosterScreen) {
        if !newScreen.filters.contains(where: { $0.id == selectedFilterID }) {
            selectedFilterID = newScreen.filters.first?.id
        }

        visibleSections = newScreen.sections(filteredBy: selectedFilterID)
    }
}
