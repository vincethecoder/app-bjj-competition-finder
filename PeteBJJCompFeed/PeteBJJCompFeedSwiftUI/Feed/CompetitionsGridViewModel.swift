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
    public private(set) var screen: PosterScreen?
    public private(set) var selectedFilterID: PosterFilter.ID?
    public private(set) var visibleSections: [PosterSection] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    @ObservationIgnored private let loader: CompetitionsFeedLoader
    @ObservationIgnored private let locale: Locale
    @ObservationIgnored private let calendar: Calendar

    public init(loader: CompetitionsFeedLoader, locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent) {
        self.loader = loader
        self.locale = locale
        self.calendar = calendar
    }

    public var title: String {
        screen?.title ?? FeedStrings.title
    }

    /// Loads the feed, keeping the current screen if loading fails.
    /// Calls made while a load is in flight are ignored.
    public func load() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let feed = try await loader.loadFeed()
            show(PosterScreenMapper.map(feed, locale: locale, calendar: calendar))

            // The app reads the cache only when the server can't be reached, so a
            // cached feed is shown with the error that explains why it may be stale.
            errorMessage = feed.cachedAt == nil ? nil : FeedStrings.connectionError
        } catch {
            errorMessage = FeedStrings.connectionError
        }
    }

    public func selectFilter(_ id: PosterFilter.ID) {
        guard screen?.filters.contains(where: { $0.id == id }) == true else { return }

        selectedFilterID = id
        visibleSections = screen?.sections(filteredBy: id) ?? []
    }

    public func dismissError() {
        errorMessage = nil
    }

    /// Shows a new screen, keeping the selected filter when the new screen still
    /// offers it, and selecting the first filter otherwise.
    private func show(_ newScreen: PosterScreen) {
        screen = newScreen

        if !newScreen.filters.contains(where: { $0.id == selectedFilterID }) {
            selectedFilterID = newScreen.filters.first?.id
        }

        visibleSections = newScreen.sections(filteredBy: selectedFilterID)
    }
}
