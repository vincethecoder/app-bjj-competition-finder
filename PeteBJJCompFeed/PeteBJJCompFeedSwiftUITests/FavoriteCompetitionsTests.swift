//
//  FavoriteCompetitionsTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/25/26.
//

import Testing
@testable import PeteBJJCompFeedSwiftUI

@MainActor
final class FavoriteCompetitionsTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func init_loadsFavoritesFromStoreWithoutSaving() {
        let (sut, store) = makeSUT(ids: ["worlds", "pans"])

        #expect(sut.ids == ["worlds", "pans"])
        #expect(sut.contains("worlds"))
        #expect(!sut.contains("brasileiro"))
        #expect(store.savedIDs.isEmpty)
    }

    @Test func toggle_addsEventThatIsNotAFavoriteAndSaves() {
        let (sut, store) = makeSUT(ids: ["worlds"])

        sut.toggle("pans")

        #expect(sut.contains("pans"))
        #expect(store.savedIDs == [["worlds", "pans"]])
    }

    @Test func toggle_removesEventThatIsAFavoriteAndSaves() {
        let (sut, store) = makeSUT(ids: ["worlds", "pans"])

        sut.toggle("worlds")

        #expect(!sut.contains("worlds"))
        #expect(store.savedIDs == [["pans"]])
    }

    @Test func reload_picksUpFavoritesChangedElsewhereWithoutSaving() {
        let (sut, store) = makeSUT(ids: ["worlds"])
        store.changeElsewhere(to: ["pans", "brasileiro"])

        sut.reload()

        #expect(sut.ids == ["pans", "brasileiro"])
        #expect(store.savedIDs.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(ids: Set<String>, sourceLocation: SourceLocation = #_sourceLocation) -> (sut: FavoriteCompetitions, store: FavoritesStoreSpy) {
        let store = FavoritesStoreSpy(ids: ids)
        let sut = FavoriteCompetitions(store: store)
        leakTracker.track(store, sourceLocation: sourceLocation)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return (sut, store)
    }
}
