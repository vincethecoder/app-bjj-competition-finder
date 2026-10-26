//
//  UserDefaultsFavoritesStore.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation

/// Stores favorites as a sorted array of IDs, which is small enough for
/// user defaults and stays stable from one save to the next.
public final class UserDefaultsFavoritesStore: FavoritesStore {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults, key: String = "favoriteCompetitionIDs") {
        self.defaults = defaults
        self.key = key
    }

    public func loadFavoriteIDs() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    public func saveFavoriteIDs(_ ids: Set<String>) {
        defaults.set(ids.sorted(), forKey: key)
    }
}
