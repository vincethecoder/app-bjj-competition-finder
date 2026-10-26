//
//  FavoritesStoreSpy.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/25/26.
//

@testable import PeteBJJCompFeedSwiftUI

/// Starts with the given favorites and records every save.
final class FavoritesStoreSpy: FavoritesStore {
    private var initialIDs: Set<String>
    private(set) var savedIDs = [Set<String>]()

    init(ids: Set<String> = []) {
        initialIDs = ids
    }

    func loadFavoriteIDs() -> Set<String> {
        savedIDs.last ?? initialIDs
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        savedIDs.append(ids)
    }

    /// Replaces what's stored without recording a save, as another device would.
    func changeElsewhere(to ids: Set<String>) {
        initialIDs = ids
        savedIDs.removeAll()
    }
}
