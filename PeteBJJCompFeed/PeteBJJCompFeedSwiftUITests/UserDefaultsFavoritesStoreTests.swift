//
//  UserDefaultsFavoritesStoreTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/25/26.
//

import Foundation
import Testing
@testable import PeteBJJCompFeedSwiftUI

/// Each test gets its own defaults suite, removed when the test ends.
final class UserDefaultsFavoritesStoreTests {
    private let suiteName = "UserDefaultsFavoritesStoreTests-\(UUID().uuidString)"
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: suiteName))
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test func loadFavoriteIDs_deliversNoFavoritesWhenNothingWasSaved() {
        #expect(makeSUT().loadFavoriteIDs().isEmpty)
    }

    @Test func loadFavoriteIDs_deliversWhatAnotherInstanceSaved() {
        makeSUT().saveFavoriteIDs(["worlds", "pans"])

        #expect(makeSUT().loadFavoriteIDs() == ["worlds", "pans"])
    }

    @Test func saveFavoriteIDs_replacesPreviouslySavedFavorites() {
        let sut = makeSUT()
        sut.saveFavoriteIDs(["worlds", "pans"])

        sut.saveFavoriteIDs(["brasileiro"])

        #expect(sut.loadFavoriteIDs() == ["brasileiro"])
    }

    @Test func saveFavoriteIDs_storesSortedArrayUnderKey() {
        makeSUT(key: "favorites").saveFavoriteIDs(["worlds", "brasileiro", "pans"])

        #expect(defaults.stringArray(forKey: "favorites") == ["brasileiro", "pans", "worlds"])
    }

    // MARK: - Helpers

    private func makeSUT(key: String = "favoriteCompetitionIDs") -> UserDefaultsFavoritesStore {
        UserDefaultsFavoritesStore(defaults: defaults, key: key)
    }
}
