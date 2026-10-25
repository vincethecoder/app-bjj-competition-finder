//
//  CompetitionsListViewModel.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Observation
import PeteBJJCompFeed

@MainActor
@Observable
public final class CompetitionsListViewModel {
    /// Where the feed is in its load cycle. Each state carries the rows on
    /// screen, so a reload or a failure never hides what was already shown.
    public enum State: Equatable {
        case idle
        case loading(rows: [CompetitionRow])
        case loaded(rows: [CompetitionRow])
        case failed(rows: [CompetitionRow], message: String)
    }

    public private(set) var state: State = .idle

    @ObservationIgnored private let loader: CompetitionsLoader

    public init(loader: CompetitionsLoader) {
        self.loader = loader
    }

    public var rows: [CompetitionRow] {
        switch state {
        case .idle: []
        case let .loading(rows), let .loaded(rows), let .failed(rows, _): rows
        }
    }

    public var isLoading: Bool {
        if case .loading = state { true } else { false }
    }

    public var errorMessage: String? {
        if case let .failed(_, message) = state { message } else { nil }
    }

    /// Loads the feed, keeping the current rows if loading fails.
    /// Calls made while a load is in flight are ignored.
    public func load() async {
        guard !isLoading else { return }

        let previousRows = rows
        state = .loading(rows: previousRows)

        do {
            state = .loaded(rows: try await loader.load().map(CompetitionRow.init))
        } catch {
            state = .failed(rows: previousRows, message: FeedStrings.connectionError)
        }
    }

    public func dismissError() {
        guard case let .failed(rows, _) = state else { return }

        state = .loaded(rows: rows)
    }
}
