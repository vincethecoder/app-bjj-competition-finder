//
//  PreviewFavoritesStore.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

#if DEBUG
/// Keeps favorites in memory, so previews don't write to user defaults.
final class PreviewFavoritesStore: FavoritesStore {
    private var ids: Set<String>

    init(ids: Set<String>) {
        self.ids = ids
    }

    func loadFavoriteIDs() -> Set<String> {
        ids
    }

    func saveFavoriteIDs(_ ids: Set<String>) {
        self.ids = ids
    }
}

extension FavoriteCompetitions {
    /// The World Championship starred, as in the preview feed.
    static var preview: FavoriteCompetitions {
        FavoriteCompetitions(store: PreviewFavoritesStore(ids: ["worlds"]))
    }
}
#endif
