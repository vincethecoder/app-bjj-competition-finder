//
//  FavoriteCompetitions.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import Observation

/// The events the user starred. The feed and the detail screen share one
/// instance, so a star added on either shows on both.
@MainActor
@Observable
public final class FavoriteCompetitions {
    public private(set) var ids: Set<String>

    @ObservationIgnored private let store: FavoritesStore

    public init(store: FavoritesStore) {
        self.store = store
        ids = store.loadFavoriteIDs()
    }

    public func contains(_ id: String) -> Bool {
        ids.contains(id)
    }

    /// Adds the event when it isn't a favorite, removes it when it is, and saves.
    public func toggle(_ id: String) {
        if ids.remove(id) == nil {
            ids.insert(id)
        }
        store.saveFavoriteIDs(ids)
    }

    /// Reads the store again after another device changed it, so the feed
    /// and the detail screen show stars added or removed there.
    public func reload() {
        let storedIDs = store.loadFavoriteIDs()
        if storedIDs != ids {
            ids = storedIDs
        }
    }
}
