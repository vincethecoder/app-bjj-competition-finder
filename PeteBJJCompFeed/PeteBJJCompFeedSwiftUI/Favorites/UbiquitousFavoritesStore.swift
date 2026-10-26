//
//  UbiquitousFavoritesStore.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/26/26.
//

/// Keeps favorites in iCloud key-value storage, so a star shows on every
/// device signed into the same account.
///
/// A local store keeps a copy. The first time, it seeds iCloud with the
/// favorites saved before syncing existed, and it keeps them whenever iCloud
/// has none, such as after the user signs out.
public final class UbiquitousFavoritesStore: FavoritesStore {
    private let cloud: UbiquitousKeyValueStore
    private let local: FavoritesStore
    private let key: String

    public init(cloud: UbiquitousKeyValueStore, local: FavoritesStore, key: String = "favoriteCompetitionIDs") {
        self.cloud = cloud
        self.local = local
        self.key = key
    }

    public func loadFavoriteIDs() -> Set<String> {
        guard let cloudIDs = cloud.array(forKey: key) as? [String] else {
            let localIDs = local.loadFavoriteIDs()
            if !localIDs.isEmpty {
                cloud.set(localIDs.sorted(), forKey: key)
            }
            return localIDs
        }

        let ids = Set(cloudIDs)
        if ids != local.loadFavoriteIDs() {
            local.saveFavoriteIDs(ids)
        }
        return ids
    }

    public func saveFavoriteIDs(_ ids: Set<String>) {
        cloud.set(ids.sorted(), forKey: key)
        local.saveFavoriteIDs(ids)
    }
}
