//
//  UbiquitousFavoritesStoreTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/26/26.
//

import Testing
@testable import PeteBJJCompFeedSwiftUI

final class UbiquitousFavoritesStoreTests {
    private let leakTracker = MemoryLeakTracker()
    private let key = "favoriteCompetitionIDs"

    deinit {
        leakTracker.verify()
    }

    @Test func load_returnsICloudFavoritesAndCopiesThemToTheDevice() {
        let (sut, cloud, local) = makeSUT(cloudIDs: ["worlds", "pans"], localIDs: ["euro"])

        #expect(sut.loadFavoriteIDs() == ["worlds", "pans"])
        #expect(local.savedIDs == [["worlds", "pans"]])
        #expect(cloud.array(forKey: key) as? [String] == ["worlds", "pans"])
    }

    @Test func load_doesNotRewriteTheDeviceCopyWhenItAlreadyMatches() {
        let (sut, _, local) = makeSUT(cloudIDs: ["worlds"], localIDs: ["worlds"])

        #expect(sut.loadFavoriteIDs() == ["worlds"])
        #expect(local.savedIDs.isEmpty)
    }

    /// Someone who unstarred everything on another device has an empty list in
    /// iCloud, which is different from having nothing there.
    @Test func load_keepsAnEmptyICloudListOverTheDeviceCopy() {
        let (sut, _, local) = makeSUT(cloudIDs: [], localIDs: ["worlds"])

        #expect(sut.loadFavoriteIDs().isEmpty)
        #expect(local.savedIDs == [[]])
    }

    @Test func load_seedsICloudWithDeviceFavoritesWhenICloudHasNone() {
        let (sut, cloud, local) = makeSUT(cloudIDs: nil, localIDs: ["worlds", "pans"])

        #expect(sut.loadFavoriteIDs() == ["worlds", "pans"])
        #expect(cloud.array(forKey: key) as? [String] == ["pans", "worlds"])
        #expect(local.savedIDs.isEmpty)
    }

    @Test func load_leavesICloudEmptyWhenNeitherHasFavorites() {
        let (sut, cloud, _) = makeSUT(cloudIDs: nil, localIDs: [])

        #expect(sut.loadFavoriteIDs().isEmpty)
        #expect(cloud.values.isEmpty)
    }

    @Test func save_writesSortedIDsToICloudAndTheDevice() {
        let (sut, cloud, local) = makeSUT(cloudIDs: nil, localIDs: [])

        sut.saveFavoriteIDs(["worlds", "brasileiro", "pans"])

        #expect(cloud.array(forKey: key) as? [String] == ["brasileiro", "pans", "worlds"])
        #expect(local.savedIDs == [["worlds", "brasileiro", "pans"]])
    }

    // MARK: - Helpers

    private func makeSUT(
        cloudIDs: [String]?,
        localIDs: Set<String>,
        sourceLocation: SourceLocation = #_sourceLocation
    ) -> (sut: UbiquitousFavoritesStore, cloud: UbiquitousKeyValueStoreStub, local: FavoritesStoreSpy) {
        let cloud = UbiquitousKeyValueStoreStub(values: cloudIDs.map { [key: $0] } ?? [:])
        let local = FavoritesStoreSpy(ids: localIDs)
        let sut = UbiquitousFavoritesStore(cloud: cloud, local: local, key: key)
        leakTracker.track(cloud, sourceLocation: sourceLocation)
        leakTracker.track(local, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, cloud, local)
    }
}
