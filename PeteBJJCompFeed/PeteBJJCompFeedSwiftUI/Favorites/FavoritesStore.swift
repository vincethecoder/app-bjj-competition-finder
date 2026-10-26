//
//  FavoritesStore.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

/// Keeps the IDs of the events the user starred between launches.
public protocol FavoritesStore {
    func loadFavoriteIDs() -> Set<String>
    func saveFavoriteIDs(_ ids: Set<String>)
}
