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
    public private(set) var rows: [CompetitionRow] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    @ObservationIgnored private let loader: CompetitionsLoader

    public init(loader: CompetitionsLoader) {
        self.loader = loader
    }

    /// Loads the feed, keeping the current rows if loading fails.
    /// Calls made while a load is in flight are ignored.
    public func load() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            rows = try await loader.load().map(CompetitionRow.init)
            errorMessage = nil
        } catch {
            errorMessage = FeedStrings.connectionError
        }
    }

    public func dismissError() {
        errorMessage = nil
    }
}
